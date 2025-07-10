class Api::V1::SummariesController < Api::V1::BaseController
  def index
    summaries = current_user.summaries
    summaries = summaries.where(summary_type: params[:type]) if params[:type].present?
    
    if params[:start_date].present? && params[:end_date].present?
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])
      summaries = summaries.for_date_range(start_date, end_date)
    end
    
    summaries = summaries.recent_first
    
    render json: summaries.map { |summary| serialize_summary(summary) }
  end

  def regenerate_all
    # Only queue monthly summaries for now
    end_date = Date.current
    start_date = 3.months.ago.to_date
    
    jobs_queued = {
      daily: 0,
      weekly: 0,
      monthly: 0
    }
    
    # Only queue monthly summaries for now
    current_date = start_date.beginning_of_month
    while current_date <= end_date
      MonthlySummaryJob.perform_later(current_user.id, current_date.end_of_month)
      jobs_queued[:monthly] += 1
      current_date += 1.month
    end
    
    render json: {
      message: 'Summary regeneration jobs queued successfully',
      jobs_queued: jobs_queued,
      note: 'Summaries will be generated in the background. This may take a few minutes.'
    }
  rescue => e
    Rails.logger.error "Failed to queue summary regeneration: #{e.message}"
    render json: { error: 'Failed to queue regeneration jobs' }, status: :internal_server_error
  end
  
  private
  
  def serialize_summary(summary)
    {
      id: summary.id,
      summary_type: summary.summary_type,
      content: summary.content,
      start_date: summary.start_date,
      end_date: summary.end_date,
      metadata: summary.metadata || {},
      created_at: summary.created_at,
      updated_at: summary.updated_at
    }
  end
end
