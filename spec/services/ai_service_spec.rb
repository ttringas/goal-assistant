require 'rails_helper'

RSpec.describe AiService do
  let(:service) { described_class.new }
  
  before do
    # Mock environment variables
    allow(ENV).to receive(:fetch).with('DEFAULT_AI_PROVIDER', 'anthropic').and_return('anthropic')
    allow(ENV).to receive(:fetch).with('AI_MAX_RETRIES', 3).and_return('3')
    allow(ENV).to receive(:fetch).with('AI_RETRY_DELAY', 1).and_return('1')
    allow(ENV).to receive(:fetch).with('AI_MODEL_ANTHROPIC', 'claude-3-5-sonnet-20241022').and_return('claude-3-5-sonnet-20241022')
    allow(ENV).to receive(:fetch).with('AI_MODEL_OPENAI', 'gpt-4o-mini').and_return('gpt-4o-mini')
  end

  describe '#initialize' do
    context 'with Anthropic API key' do
      before do
        allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test-anthropic-key')
        allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
      end

      it 'creates Anthropic client' do
        expect(Anthropic::Client).to receive(:new).with(api_key: 'test-anthropic-key')
        described_class.new
      end
    end

    context 'with OpenAI API key' do
      before do
        allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return(nil)
        allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return('test-openai-key')
      end

      it 'creates OpenAI client' do
        expect(OpenAI::Client).to receive(:new).with(access_token: 'test-openai-key')
        described_class.new
      end
    end
  end

  describe '#infer_goal_type' do
    let(:mock_client) { double('ai_client') }
    
    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test-key')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
      allow(Anthropic::Client).to receive(:new).and_return(mock_client)
    end

    context 'with valid response' do
      let(:messages_double) { double('messages') }
      
      before do
        allow(mock_client).to receive(:messages).and_return(messages_double)
        allow(messages_double).to receive(:create).and_return({
          "content" => [{ "text" => "habit" }]
        })
      end

      it 'returns habit for habit-like goals' do
        result = service.infer_goal_type('Daily meditation', 'Meditate for 20 minutes every morning')
        expect(result).to eq('habit')
      end
    end

    context 'with milestone response' do
      let(:messages_double) { double('messages') }
      
      before do
        allow(mock_client).to receive(:messages).and_return(messages_double)
        allow(messages_double).to receive(:create).and_return({
          "content" => [{ "text" => "milestone" }]
        })
      end

      it 'returns milestone for achievement goals' do
        result = service.infer_goal_type('Run a marathon', 'Complete a full marathon by year end')
        expect(result).to eq('milestone')
      end
    end

    context 'with project response' do
      let(:messages_double) { double('messages') }
      
      before do
        allow(mock_client).to receive(:messages).and_return(messages_double)
        allow(messages_double).to receive(:create).and_return({
          "content" => [{ "text" => "project" }]
        })
      end

      it 'returns project for complex goals' do
        result = service.infer_goal_type('Build a mobile app', 'Design and launch a fitness tracking app')
        expect(result).to eq('project')
      end
    end

    context 'with unparseable response' do
      let(:messages_double) { double('messages') }
      
      before do
        allow(mock_client).to receive(:messages).and_return(messages_double)
        allow(messages_double).to receive(:create).and_return({
          "content" => [{ "text" => "I'm not sure about this goal type" }]
        })
      end

      it 'returns nil' do
        result = service.infer_goal_type('Unclear goal', 'Something vague')
        expect(result).to be_nil
      end
    end
  end

  describe '#suggest_goal_improvements' do
    let(:mock_client) { double('ai_client') }
    
    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test-key')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return(nil)
      allow(Anthropic::Client).to receive(:new).and_return(mock_client)
    end

    context 'with valid response' do
      let(:messages_double) { double('messages') }
      let(:suggestions) { "1. Add specific time commitment\n2. Define measurable outcomes\n3. Set a clear deadline" }
      
      before do
        allow(mock_client).to receive(:messages).and_return(messages_double)
        allow(messages_double).to receive(:create).and_return({
          "content" => [{ "text" => suggestions }]
        })
      end

      it 'returns improvement suggestions' do
        result = service.suggest_goal_improvements('Get fit', 'Exercise more', 'habit')
        expect(result).to eq(suggestions)
      end
    end
  end

  describe '#generate_response with fallback' do
    let(:anthropic_client) { double('anthropic_client') }
    let(:openai_client) { double('openai_client') }
    
    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('test-anthropic')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return('test-openai')
      allow(Anthropic::Client).to receive(:new).and_return(anthropic_client)
      allow(OpenAI::Client).to receive(:new).and_return(openai_client)
    end

    context 'when Anthropic returns 529 error' do
      let(:messages_double) { double('messages') }
      let(:chat_double) { double('chat') }
      
      before do
        allow(anthropic_client).to receive(:messages).and_return(messages_double)
        allow(messages_double).to receive(:create).and_raise(
          Net::HTTPServiceUnavailable.new('1.1', '529', 'Overloaded')
        )
        
        allow(openai_client).to receive(:chat).and_return({
          "choices" => [{ "message" => { "content" => "OpenAI response" } }]
        })
      end

      it 'falls back to OpenAI' do
        service = described_class.new
        result = service.generate_response('test prompt', 'test system')
        expect(result).to eq('OpenAI response')
      end
    end

    context 'when both providers fail' do
      before do
        allow(anthropic_client).to receive(:messages).and_raise(
          Net::HTTPServiceUnavailable.new('1.1', '529', 'Overloaded')
        )
        
        allow(openai_client).to receive(:chat).and_raise(
          StandardError.new('OpenAI error')
        )
      end

      it 'raises an error' do
        service = described_class.new
        expect {
          service.generate_response('test prompt', 'test system')
        }.to raise_error(AiService::Error)
      end
    end
  end
end