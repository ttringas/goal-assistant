require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:goals).dependent(:destroy) }
    it { should have_many(:progress_entries).dependent(:destroy) }
    it { should have_many(:summaries).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe 'devise modules' do
    it 'includes database authenticatable' do
      expect(User.devise_modules).to include(:database_authenticatable)
    end

    it 'includes jwt authenticatable' do
      expect(User.devise_modules).to include(:jwt_authenticatable)
    end
  end

  describe '#has_custom_api_keys?' do
    let(:user) { create(:user) }

    context 'with no custom API keys' do
      it 'returns false' do
        expect(user.has_custom_api_keys?).to be false
      end
    end

    context 'with Anthropic API key' do
      before { user.update(anthropic_api_key: 'sk-ant-test') }
      
      it 'returns true' do
        expect(user.has_custom_api_keys?).to be true
      end
    end

    context 'with OpenAI API key' do
      before { user.update(openai_api_key: 'sk-test') }
      
      it 'returns true' do
        expect(user.has_custom_api_keys?).to be true
      end
    end

    context 'with both API keys' do
      before do
        user.update(
          anthropic_api_key: 'sk-ant-test',
          openai_api_key: 'sk-test'
        )
      end
      
      it 'returns true' do
        expect(user.has_custom_api_keys?).to be true
      end
    end
  end

  describe '#api_key_for' do
    let(:user) { create(:user) }

    before do
      allow(ENV).to receive(:[]).with('ANTHROPIC_API_KEY').and_return('env-anthropic-key')
      allow(ENV).to receive(:[]).with('OPENAI_API_KEY').and_return('env-openai-key')
    end

    context 'with no custom API keys' do
      it 'returns environment API key for anthropic' do
        expect(user.api_key_for('anthropic')).to eq('env-anthropic-key')
      end

      it 'returns environment API key for openai' do
        expect(user.api_key_for('openai')).to eq('env-openai-key')
      end
    end

    context 'with custom API keys' do
      before do
        user.update(
          anthropic_api_key: 'custom-anthropic-key',
          openai_api_key: 'custom-openai-key'
        )
      end

      it 'returns custom API key for anthropic' do
        expect(user.api_key_for('anthropic')).to eq('custom-anthropic-key')
      end

      it 'returns custom API key for openai' do
        expect(user.api_key_for('openai')).to eq('custom-openai-key')
      end
    end

    it 'returns nil for unknown provider' do
      expect(user.api_key_for('unknown')).to be_nil
    end
  end

  describe 'encryption' do
    let(:user) { create(:user) }

    it 'encrypts anthropic_api_key' do
      user.update(anthropic_api_key: 'sk-ant-test')
      user.reload
      
      # The encrypted value should not be the same as the plain text
      encrypted_value = user.read_attribute_before_type_cast(:anthropic_api_key)
      expect(encrypted_value).not_to eq('sk-ant-test')
      
      # But accessing it normally should decrypt it
      expect(user.anthropic_api_key).to eq('sk-ant-test')
    end

    it 'encrypts openai_api_key' do
      user.update(openai_api_key: 'sk-test')
      user.reload
      
      # The encrypted value should not be the same as the plain text
      encrypted_value = user.read_attribute_before_type_cast(:openai_api_key)
      expect(encrypted_value).not_to eq('sk-test')
      
      # But accessing it normally should decrypt it
      expect(user.openai_api_key).to eq('sk-test')
    end
  end
end