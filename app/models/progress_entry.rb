class ProgressEntry < ApplicationRecord
  belongs_to :user
  belongs_to :goal, optional: true

  validates :content, presence: true
  validates :entry_date, presence: true
  validates :entry_date, uniqueness: { scope: :user_id }

  scope :by_date_range, ->(start_date, end_date) { where(entry_date: start_date..end_date) }
  scope :recent, -> { order(entry_date: :desc) }

  def self.for_date(date, user)
    where(user: user).find_by(entry_date: date)
  end

  def self.upsert_for_date(date, user, attributes)
    entry = where(user: user).find_or_initialize_by(entry_date: date)
    entry.assign_attributes(attributes)
    entry.save!
    entry
  end
end
