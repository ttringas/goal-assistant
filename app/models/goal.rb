class Goal < ApplicationRecord
  belongs_to :user
  has_many :progress_entries, dependent: :destroy

  validates :title, presence: true
  validates :goal_type, inclusion: { in: %w[habit milestone project] }, allow_nil: true

  # Default ordering by created_at (newest first)
  default_scope { order(created_at: :desc) }

  scope :active, -> { where(archived_at: nil, completed_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :incomplete, -> { where(completed_at: nil) }

  def complete!
    update!(completed_at: Time.current)
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def completed?
    completed_at.present?
  end

  def archived?
    archived_at.present?
  end
end
