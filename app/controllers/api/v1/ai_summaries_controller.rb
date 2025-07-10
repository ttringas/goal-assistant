class Api::V1::AiSummariesController < Api::V1::BaseController
  def index
    summaries = current_user.ai_summaries
    
    summaries = summaries.where(summary_type: params[:type]) if params[:type].present?
    
    if params[:start_date].present? && params[:end_date].present?
      summaries = summaries.for_period(params[:start_date], params[:end_date])
    end

    summaries = summaries.recent.limit(params[:limit] || 50)

    render json: summaries
  end

  def today
    summary = current_user.ai_summaries.daily.for_date(Date.current)
    
    if summary
      render json: summary
    else
      render json: { message: 'No insight available for today yet' }, status: :not_found
    end
  end

  def show
    summary = current_user.ai_summaries.find(params[:id])
    render json: summary
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Summary not found' }, status: :not_found
  end
end