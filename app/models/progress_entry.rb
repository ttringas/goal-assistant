class ProgressEntry < ApplicationRecord
  belongs_to :goal

  validates :content, presence: true
  validates :entry_date, presence: true
  validates :entry_date, uniqueness: true

  scope :by_date_range, ->(start_date, end_date) { where(entry_date: start_date..end_date) }
  scope :recent, -> { order(entry_date: :desc) }

  def self.for_date(date)
    find_by(entry_date: date)
  end

  def self.upsert_for_date(date, attributes)
    entry = find_or_initialize_by(entry_date: date)
    entry.assign_attributes(attributes)
    entry.save!
    entry
  end
end
