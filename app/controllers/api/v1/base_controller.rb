class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!
  
  private
  
  def authenticate_user!
    unless user_signed_in?
      render json: { error: 'You need to sign in or sign up before continuing.' }, status: :unauthorized
    end
  end
end