class Api::V1::UsersController < Api::V1::BaseController
  def current
    render json: {
      id: current_user.id,
      email: current_user.email,
      has_custom_api_keys: current_user.has_custom_api_keys?,
      created_at: current_user.created_at
    }
  end

  def update
    if current_user.update(user_params)
      render json: {
        id: current_user.id,
        email: current_user.email,
        has_custom_api_keys: current_user.has_custom_api_keys?,
        created_at: current_user.created_at
      }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_api_keys
    if current_user.update(api_key_params)
      render json: {
        message: 'API keys updated successfully',
        has_custom_api_keys: current_user.has_custom_api_keys?
      }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email)
  end

  def api_key_params
    params.require(:user).permit(:anthropic_api_key, :openai_api_key)
  end
end