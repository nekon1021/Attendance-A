class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }
  
  # 退勤時間が存在しない場合、出勤時間は無効
  validate :started_at_is_invalid_without_a_finished_at, on: :closing
  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def started_at_is_invalid_without_a_finished_at
    errors.add(:finished_at, "が必要です") if finished_at.blank? && started_at.present?
  end

  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end
  
  def started_at_rounded
    round_minutes(started_at)
  end
  
  def finished_at_rounded
    round_minutes(finished_at)
  end
  
  private
  
  def round_minutes(time)
    return nil unless time
    Time.zone.local(time.year, time.month, time.day, time.hour, (time.min/15 * 15), 0)
  end
end