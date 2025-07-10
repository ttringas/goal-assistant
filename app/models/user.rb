class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  # Associations
  has_many :goals, dependent: :destroy
  has_many :progress_entries, dependent: :destroy
  has_many :summaries, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true

  # Encrypt API keys
  encrypts :anthropic_api_key
  encrypts :openai_api_key

  # Check if user has custom API keys
  def has_custom_api_keys?
    anthropic_api_key.present? || openai_api_key.present?
  end

  # Get the appropriate API key for a provider
  def api_key_for(provider)
    case provider
    when 'anthropic'
      anthropic_api_key.presence || ENV['ANTHROPIC_API_KEY']
    when 'openai'
      openai_api_key.presence || ENV['OPENAI_API_KEY']
    else
      nil
    end
  end
end
