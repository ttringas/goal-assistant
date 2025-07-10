class AiService
  class Error < StandardError; end
  class RateLimitError < Error; end
  class InvalidResponseError < Error; end

  def initialize
    @anthropic_client = create_anthropic_client if anthropic_available?
    @openai_client = create_openai_client if openai_available?
    @default_provider = ENV.fetch('DEFAULT_AI_PROVIDER', 'anthropic').to_sym
    @max_retries = ENV.fetch('AI_MAX_RETRIES', 3).to_i
    @retry_delay = ENV.fetch('AI_RETRY_DELAY', 1).to_i
  end

  def generate_response(prompt, system_prompt = nil, temperature: 0.7)
    providers = [@default_provider]
    providers << (providers.first == :anthropic ? :openai : :anthropic) if both_providers_available?

    last_error = nil
    
    providers.each do |provider|
      begin
        Rails.logger.info "Attempting AI request with #{provider}"
        response = send("generate_with_#{provider}", prompt, system_prompt, temperature: temperature)
        return response if response.present?
      rescue RateLimitError => e
        Rails.logger.warn "Rate limit hit with #{provider}: #{e.message}"
        last_error = e
        next # Try next provider
      rescue => e
        Rails.logger.error "Error with #{provider}: #{e.class} - #{e.message}"
        last_error = e
        # Don't continue to next provider if it's not a rate limit error
        if e.is_a?(StandardError) && !e.is_a?(RateLimitError)
          last_error = Error.new("#{provider} error: #{e.message}")
        end
        next # Try next provider
      end
    end

    raise last_error || Error.new("Failed to generate response with any provider")
  end

  def infer_goal_type(goal_title, goal_description)
    prompt = AiPrompts.render_template(:goal_type_inference, {
      title: goal_title,
      description: goal_description || "No description provided"
    })
    system_prompt = AiPrompts.system_prompt_for(:goal_categorization)
    
    response = generate_response(prompt, system_prompt, temperature: 0.3)
    parse_goal_type(response)
  end

  def suggest_goal_improvements(goal_title, goal_description, goal_type = nil)
    prompt = AiPrompts.render_template(:goal_improvement, {
      title: goal_title,
      description: goal_description || "No description provided",
      goal_type: goal_type || "Not specified"
    })
    system_prompt = AiPrompts.system_prompt_for(:goal_improvement)
    
    generate_response(prompt, system_prompt, temperature: 0.7)
  end

  private

  def anthropic_available?
    ENV['ANTHROPIC_API_KEY'].present?
  end

  def openai_available?
    ENV['OPENAI_API_KEY'].present?
  end

  def both_providers_available?
    anthropic_available? && openai_available?
  end

  def create_anthropic_client
    require 'anthropic'
    Anthropic::Client.new(
      api_key: ENV['ANTHROPIC_API_KEY']
    )
  end

  def create_openai_client
    require 'openai'
    OpenAI::Client.new(
      access_token: ENV['OPENAI_API_KEY']
    )
  end

  def generate_with_anthropic(prompt, system_prompt, temperature:)
    return nil unless @anthropic_client

    retries = 0
    begin
      response = @anthropic_client.messages.create(
        model: ENV.fetch('AI_MODEL_ANTHROPIC', 'claude-3-5-sonnet-20241022'),
        messages: [{ role: "user", content: prompt }],
        system: system_prompt,
        temperature: temperature,
        max_tokens: 1024
      )

      check_anthropic_response(response)
      # The Anthropic gem returns a response object, not a hash
      if response.respond_to?(:content)
        response.content.first.text
      else
        response.dig("content", 0, "text")
      end
    rescue Net::HTTPTooManyRequests, Net::HTTPServiceUnavailable => e
      if e.message.include?("529") || retries >= @max_retries
        raise RateLimitError.new("Anthropic rate limit: #{e.message}")
      end
      
      retries += 1
      sleep(@retry_delay * retries)
      retry
    end
  end

  def generate_with_openai(prompt, system_prompt, temperature:)
    return nil unless @openai_client

    messages = []
    messages << { role: "system", content: system_prompt } if system_prompt.present?
    messages << { role: "user", content: prompt }

    retries = 0
    begin
      response = @openai_client.chat(
        parameters: {
          model: ENV.fetch('AI_MODEL_OPENAI', 'gpt-4o-mini'),
          messages: messages,
          temperature: temperature,
          max_tokens: 1024
        }
      )

      check_openai_response(response)
      response.dig("choices", 0, "message", "content")
    rescue Net::HTTPTooManyRequests => e
      if retries >= @max_retries
        raise RateLimitError.new("OpenAI rate limit: #{e.message}")
      end
      
      retries += 1
      sleep(@retry_delay * retries)
      retry
    end
  end

  def check_anthropic_response(response)
    # Handle both hash responses and object responses from the Anthropic gem
    error = nil
    error_type = nil
    error_message = nil
    
    if response.is_a?(Hash) && response["error"]
      error = response["error"]
      error_type = error["type"]
      error_message = error["message"]
    elsif response.respond_to?(:error) && response.error
      error = response.error
      error_type = error.type if error.respond_to?(:type)
      error_message = error.message if error.respond_to?(:message)
    end
    
    if error
      if error_type == "rate_limit_error"
        raise RateLimitError.new(error_message || "Rate limit exceeded")
      else
        raise InvalidResponseError.new("Anthropic error: #{error_message || 'Unknown error'}")
      end
    end
  end

  def check_openai_response(response)
    if response["error"]
      error_type = response.dig("error", "type")
      error_message = response.dig("error", "message")
      
      if error_type == "rate_limit_error"
        raise RateLimitError.new(error_message)
      else
        raise InvalidResponseError.new("OpenAI error: #{error_message}")
      end
    end
  end


  def parse_goal_type(response)
    cleaned = response.to_s.strip.downcase
    
    return 'habit' if cleaned.include?('habit')
    return 'milestone' if cleaned.include?('milestone')
    return 'project' if cleaned.include?('project')
    
    nil # Default if unable to parse
  end
end