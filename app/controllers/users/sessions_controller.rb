class Users::SessionsController < ApplicationController
  def create
    user = User.find_for_database_authentication(email: params.dig(:user, :email))
    
    if user&.valid_password?(params.dig(:user, :password))
      # Sign in the user with Warden to trigger JWT generation
      sign_in(user, store: false)
      
      render json: {
        status: { code: 200, message: 'Logged in successfully.' },
        data: UserSerializer.new(user).serializable_hash[:data][:attributes]
      }, status: :ok
    else
      render json: {
        error: "Invalid Email or password."
      }, status: :unauthorized
    end
  end

  def destroy
    if current_user
      sign_out(current_user)
      render json: {
        status: 200,
        message: "Logged out successfully"
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end