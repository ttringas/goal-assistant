#!/usr/bin/env ruby
# Script to test AI API integration with real API calls
# Usage: rails runner script/test_ai_apis.rb

puts "\n🤖 Testing AI API Integration"
puts "=" * 50

# Check environment variables
def check_env_vars
  puts "\n📋 Checking environment variables..."
  
  anthropic_key = ENV['ANTHROPIC_API_KEY']
  openai_key = ENV['OPENAI_API_KEY']
  
  if anthropic_key.present?
    puts "✅ ANTHROPIC_API_KEY is set (#{anthropic_key[0..10]}...)"
  else
    puts "❌ ANTHROPIC_API_KEY is not set"
  end
  
  if openai_key.present?
    puts "✅ OPENAI_API_KEY is set (#{openai_key[0..10]}...)"
  else
    puts "❌ OPENAI_API_KEY is not set"
  end
  
  puts "📋 Default provider: #{ENV.fetch('DEFAULT_AI_PROVIDER', 'anthropic')}"
  
  return anthropic_key.present? || openai_key.present?
end

# Test goal type inference
def test_goal_type_inference(service)
  puts "\n🎯 Testing Goal Type Inference..."
  
  test_cases = [
    { title: "Meditate daily", description: "Practice mindfulness meditation for 20 minutes each morning", expected: "habit" },
    { title: "Run a marathon", description: "Complete the NYC marathon in under 4 hours", expected: "milestone" },
    { title: "Build a mobile app", description: "Design, develop, and launch a fitness tracking app on iOS and Android", expected: "project" }
  ]
  
  test_cases.each do |test|
    begin
      print "  Testing: '#{test[:title]}' -> "
      result = service.infer_goal_type(test[:title], test[:description])
      
      if result == test[:expected]
        puts "✅ #{result} (correct)"
      else
        puts "⚠️  #{result} (expected #{test[:expected]})"
      end
    rescue => e
      puts "❌ Error: #{e.message}"
    end
  end
end

# Test goal improvement suggestions
def test_goal_improvements(service)
  puts "\n💡 Testing Goal Improvement Suggestions..."
  
  test_cases = [
    { title: "Get fit", description: "Exercise more", goal_type: "habit" },
    { title: "Learn Spanish", description: nil, goal_type: "project" }
  ]
  
  test_cases.each do |test|
    begin
      puts "\n  Goal: '#{test[:title]}'"
      puts "  Description: #{test[:description] || 'None'}"
      puts "  Type: #{test[:goal_type]}"
      
      suggestions = service.suggest_goal_improvements(test[:title], test[:description], test[:goal_type])
      
      if suggestions.present?
        puts "  ✅ Suggestions received:"
        suggestions.split("\n").each do |line|
          puts "    #{line}" if line.strip.present?
        end
      else
        puts "  ❌ No suggestions received"
      end
    rescue => e
      puts "  ❌ Error: #{e.message}"
    end
  end
end

# Test provider fallback
def test_provider_fallback(service)
  puts "\n🔄 Testing Provider Fallback..."
  
  # Temporarily force a provider to test fallback
  original_provider = ENV['DEFAULT_AI_PROVIDER']
  
  begin
    # Test with Anthropic as default
    ENV['DEFAULT_AI_PROVIDER'] = 'anthropic'
    puts "  Testing with Anthropic as primary..."
    response = service.generate_response("Say 'Hello from AI'", "You are a helpful assistant", temperature: 0.1)
    puts "  ✅ Response: #{response[0..50]}..." if response.present?
    
    # Test with OpenAI as default
    if ENV['OPENAI_API_KEY'].present?
      ENV['DEFAULT_AI_PROVIDER'] = 'openai'
      puts "\n  Testing with OpenAI as primary..."
      response = service.generate_response("Say 'Hello from AI'", "You are a helpful assistant", temperature: 0.1)
      puts "  ✅ Response: #{response[0..50]}..." if response.present?
    end
  rescue => e
    puts "  ❌ Error: #{e.message}"
  ensure
    ENV['DEFAULT_AI_PROVIDER'] = original_provider
  end
end

# Test API endpoints
def test_api_endpoints
  puts "\n🌐 Testing API Endpoints..."
  
  require 'net/http'
  require 'json'
  
  base_url = "http://localhost:3000"
  
  # Test goal type inference endpoint
  begin
    uri = URI("#{base_url}/api/v1/ai/infer_goal_type")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request.body = { title: "Read 30 minutes daily", description: "Read books every day" }.to_json
    
    response = http.request(request)
    
    if response.code == "200"
      data = JSON.parse(response.body)
      puts "  ✅ Goal type inference endpoint: #{data['goal_type']}"
    else
      puts "  ❌ Goal type inference endpoint failed: #{response.code}"
      puts "     Response: #{response.body}"
    end
  rescue => e
    puts "  ⚠️  Could not test endpoint (server may not be running): #{e.message}"
  end
  
  # Test goal improvement endpoint
  begin
    uri = URI("#{base_url}/api/v1/ai/improve_goal")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri)
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/json'
    request.body = { title: "Exercise more", description: "Get in shape", goal_type: "habit" }.to_json
    
    response = http.request(request)
    
    if response.code == "200"
      data = JSON.parse(response.body)
      puts "  ✅ Goal improvement endpoint: received #{data['formatted_suggestions']&.length || 0} suggestions"
    else
      puts "  ❌ Goal improvement endpoint failed: #{response.code}"
      puts "     Response: #{response.body}"
    end
  rescue => e
    puts "  ⚠️  Could not test endpoint: #{e.message}"
  end
end

# Test direct API calls
def test_direct_api_calls
  puts "\n🔌 Testing Direct API Calls..."
  
  # Test Anthropic directly
  if ENV['ANTHROPIC_API_KEY'].present?
    begin
      puts "\n  Testing direct Anthropic API call..."
      client = Anthropic::Client.new(api_key: ENV['ANTHROPIC_API_KEY'])
      response = client.messages.create(
        model: ENV.fetch('AI_MODEL_ANTHROPIC', 'claude-3-5-sonnet-20241022'),
        messages: [{ role: "user", content: "Say 'Anthropic API is working'" }],
        max_tokens: 50
      )
      
      if response.respond_to?(:content) && response.content
        text = response.content.first.text rescue nil
        puts "  ✅ Anthropic API response: #{text[0..50]}" if text
      elsif response.is_a?(Hash) && response["content"]
        puts "  ✅ Anthropic API response: #{response.dig("content", 0, "text")[0..50]}"
      else
        error_msg = response.respond_to?(:error) ? response.error : "Unknown response format"
        puts "  ❌ Anthropic API error: #{error_msg}"
      end
    rescue => e
      puts "  ❌ Anthropic API error: #{e.message}"
    end
  end
  
  # Test OpenAI directly
  if ENV['OPENAI_API_KEY'].present?
    begin
      puts "\n  Testing direct OpenAI API call..."
      client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
      response = client.chat(
        parameters: {
          model: ENV.fetch('AI_MODEL_OPENAI', 'gpt-4o-mini'),
          messages: [{ role: "user", content: "Say 'OpenAI API is working'" }],
          max_tokens: 50
        }
      )
      
      if response["choices"]
        puts "  ✅ OpenAI API response: #{response.dig("choices", 0, "message", "content")[0..50]}"
      else
        puts "  ❌ OpenAI API error: #{response["error"]}"
      end
    rescue => e
      puts "  ❌ OpenAI API error: #{e.message}"
    end
  end
end

# Main execution
if check_env_vars
  puts "\n🚀 Starting AI service tests..."
  
  begin
    # Load Rails environment if not already loaded
    require_relative '../config/environment' unless defined?(Rails)
    
    service = AiService.new
    
    test_goal_type_inference(service)
    test_goal_improvements(service)
    test_provider_fallback(service)
    test_direct_api_calls
    test_api_endpoints
    
    puts "\n✅ AI API testing complete!"
  rescue => e
    puts "\n❌ Fatal error: #{e.message}"
    puts e.backtrace.first(5).join("\n")
  end
else
  puts "\n❌ Please set at least one API key to run tests"
  puts "Add to your .env file:"
  puts "  ANTHROPIC_API_KEY=your_key_here"
  puts "  OPENAI_API_KEY=your_key_here"
end

puts "\n" + "=" * 50