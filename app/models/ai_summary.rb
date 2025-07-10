class AiSummary < ApplicationRecord
  SUMMARY_TYPES = %w[daily weekly monthly].freeze

  validates :content, presence: true
  validates :summary_type, inclusion: { in: SUMMARY_TYPES }
  validates :period_start, presence: true
  validates :period_end, presence: true
  validate :period_end_after_start

  scope :daily, -> { where(summary_type: 'daily') }
  scope :weekly, -> { where(summary_type: 'weekly') }
  scope :monthly, -> { where(summary_type: 'monthly') }
  scope :for_period, ->(start_date, end_date) { 
    where('(period_start <= ? AND period_end >= ?) OR (period_start >= ? AND period_start <= ?)', 
          end_date, start_date, start_date, end_date) 
  }
  scope :recent, -> { order(period_start: :desc) }

  def self.for_date(date)
    where('period_start <= ? AND period_end >= ?', date, date).first
  end

  def period_range
    period_start..period_end
  end

  def period_label
    case summary_type
    when 'daily'
      period_start.strftime('%B %d, %Y')
    when 'weekly'
      "Week of #{period_start.strftime('%b %d-%d')}"
    when 'monthly'
      period_start.strftime('%B %Y')
    end
  end

  private

  def period_end_after_start
    return unless period_start && period_end
    errors.add(:period_end, 'must be after or equal to period start') if period_end < period_start
  end
end