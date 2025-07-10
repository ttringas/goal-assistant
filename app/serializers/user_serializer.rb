class UserSerializer
  def initialize(user)
    @user = user
  end

  def serializable_hash
    {
      data: {
        attributes: {
          id: @user.id,
          email: @user.email,
          created_at: @user.created_at,
          has_custom_api_keys: @user.has_custom_api_keys?
        }
      }
    }
  end
end