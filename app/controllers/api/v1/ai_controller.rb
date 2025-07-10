class Api::V1::AiController < Api::V1::BaseController
  before_action :initialize_ai_service

  def infer_goal_type
    title = params[:title]
    description = params[:description]

    if title.blank?
      render json: { error: 'Title is required' }, status: :unprocessable_entity
      return
    end

    begin
      goal_type = @ai_service.infer_goal_type(title, description)
      
      if goal_type.present?
        render json: { goal_type: goal_type }
      else
        render json: { goal_type: nil, message: 'Unable to infer goal type' }
      end
    rescue AiService::Error => e
      Rails.logger.error "AI Service Error: #{e.message}"
      render json: { error: 'AI service temporarily unavailable' }, status: :service_unavailable
    end
  end

  def improve_goal
    title = params[:title]
    description = params[:description]
    goal_type = params[:goal_type]

    if title.blank?
      render json: { error: 'Title is required' }, status: :unprocessable_entity
      return
    end

    begin
      suggestions = @ai_service.suggest_goal_improvements(title, description, goal_type)
      
      render json: { 
        suggestions: suggestions,
        formatted_suggestions: format_suggestions(suggestions)
      }
    rescue AiService::Error => e
      Rails.logger.error "AI Service Error: #{e.message}"
      render json: { error: 'AI service temporarily unavailable' }, status: :service_unavailable
    end
  end

  private

  def initialize_ai_service
    @ai_service = AiService.new(current_user)
  rescue => e
    Rails.logger.error "Failed to initialize AI service: #{e.message}"
    render json: { error: 'AI service configuration error' }, status: :internal_server_error
  end

  def format_suggestions(raw_suggestions)
    # Split suggestions into an array for easier frontend rendering
    suggestions = raw_suggestions.split(/\n+/).select { |line| line.strip.present? }
    
    # Remove numbering if present and clean up
    suggestions.map do |suggestion|
      suggestion.gsub(/^\d+\.\s*/, '').strip
    end.select { |s| s.length > 10 } # Filter out very short lines
  end
end