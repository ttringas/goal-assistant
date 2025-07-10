class Summary < ApplicationRecord
  SUMMARY_TYPES = %w[daily weekly monthly].freeze

  validates :summary_type, presence: true, inclusion: { in: SUMMARY_TYPES }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :content, presence: true

  validate :end_date_after_start_date
  validates :summary_type, uniqueness: { scope: [:start_date, :end_date] }

  scope :daily, -> { where(summary_type: 'daily') }
  scope :weekly, -> { where(summary_type: 'weekly') }
  scope :monthly, -> { where(summary_type: 'monthly') }
  scope :for_date_range, ->(start_date, end_date) { where('start_date >= ? AND end_date <= ?', start_date, end_date) }
  scope :recent_first, -> { order(start_date: :desc) }

  def self.find_or_initialize_for(summary_type, start_date, end_date)
    find_or_initialize_by(
      summary_type: summary_type,
      start_date: start_date,
      end_date: end_date
    )
  end

  private

  def end_date_after_start_date
    return unless start_date && end_date
    errors.add(:end_date, 'must be after or equal to start date') if end_date < start_date
  end
end
