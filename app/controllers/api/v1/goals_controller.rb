class Api::V1::GoalsController < ApplicationController
  before_action :set_goal, only: [:show, :update, :destroy, :complete, :archive]

  def index
    goals = Goal.all
    goals = goals.active if params[:active] == 'true'
    goals = goals.archived if params[:archived] == 'true'
    goals = goals.completed if params[:completed] == 'true'
    goals = goals.incomplete if params[:incomplete] == 'true'

    render json: goals
  end

  def show
    render json: @goal
  end

  def create
    goal = Goal.new(goal_params)

    if goal.save
      render json: goal, status: :created
    else
      render json: { errors: goal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @goal.update(goal_params)
      render json: @goal
    else
      render json: { errors: @goal.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @goal.destroy
    head :no_content
  end

  def complete
    @goal.complete!
    render json: @goal
  end

  def archive
    @goal.archive!
    render json: @goal
  end

  private

  def set_goal
    @goal = Goal.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Goal not found' }, status: :not_found
  end

  def goal_params
    params.require(:goal).permit(:title, :description, :target_date, :goal_type)
  end
end
