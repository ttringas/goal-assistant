class Api::V1::ProgressEntriesController < Api::V1::BaseController
  def index
    entries = current_user.progress_entries.includes(:goal)

    if params[:start_date].present? && params[:end_date].present?
      entries = entries.by_date_range(params[:start_date], params[:end_date])
    end

    entries = entries.recent

    render json: entries, include: :goal
  end

  def today
    entry = ProgressEntry.includes(:goal).for_date(Date.current, current_user)
    
    if entry
      render json: entry.as_json(include: :goal)
    else
      render json: { entry_date: Date.current, content: '' }
    end
  end

  def create
    entry = ProgressEntry.upsert_for_date(
      params[:progress_entry][:entry_date] || Date.current,
      current_user,
      progress_entry_params.merge(user: current_user)
    )

    render json: entry.as_json(include: :goal), status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def update
    entry = current_user.progress_entries.find(params[:id])

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
    permitted = params.require(:progress_entry).permit(:content, :entry_date, :goal_id)
    # Ensure goal_id belongs to current_user if provided
    if permitted[:goal_id].present?
      goal = current_user.goals.find_by(id: permitted[:goal_id])
      permitted[:goal_id] = goal&.id
    end
    permitted
  end
end
