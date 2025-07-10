class Users::RegistrationsController < ApplicationController
  def create
    user = User.new(sign_up_params)
    
    if user.save
      sign_in(user, store: false)
      render json: {
        status: { code: 200, message: 'Signed up successfully.' },
        data: UserSerializer.new(user).serializable_hash[:data][:attributes]
      }
    else
      render json: {
        status: { message: "User couldn't be created successfully. #{user.errors.full_messages.to_sentence}" }
      }, status: :unprocessable_entity
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end