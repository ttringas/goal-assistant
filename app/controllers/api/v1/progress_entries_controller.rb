class Api::V1::ProgressEntriesController < ApplicationController
  def index
    entries = ProgressEntry.includes(:goal)

    if params[:start_date].present? && params[:end_date].present?
      entries = entries.by_date_range(params[:start_date], params[:end_date])
    end

    entries = entries.recent

    render json: entries, include: :goal
  end

  def today
    entry = ProgressEntry.includes(:goal).for_date(Date.current)
    
    if entry
      render json: entry.as_json(include: :goal)
    else
      render json: { entry_date: Date.current, content: '' }
    end
  end

  def create
    entry = ProgressEntry.upsert_for_date(
      params[:progress_entry][:entry_date] || Date.current,
      progress_entry_params
    )

    render json: entry.as_json(include: :goal), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def update
    entry = ProgressEntry.find(params[:id])

    if entry.update(progress_entry_params)
      render json: entry.as_json(include: :goal)
    else
      render json: { errors: entry.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Progress entry not found' }, status: :not_found
  end

  private

  def progress_entry_params
    params.require(:progress_entry).permit(:content, :entry_date, :goal_id)
  end
end
