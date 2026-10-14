class TimeSlot < ApplicationRecord
  validates :day_of_week, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time

  DAYS = {
    1 => "Lunes",
    2 => "Martes",
    3 => "Miércoles",
    4 => "Jueves",
    5 => "Viernes",
    6 => "Sábado",
    7 => "Domingo",
    0 => "Domingo"
  }.freeze

  def day_name
    DAYS[day_of_week] || "Día #{day_of_week}"
  end

  def formatted_time_range
    st = start_time ? start_time.strftime("%H:%M") : "--:--"
    et = end_time ? end_time.strftime("%H:%M") : "--:--"
    "#{st} a #{et} hs"
  end

  private

  def end_time_after_start_time
    return if end_time.blank? || start_time.blank?

    # Allow midnight rollover (e.g. 23:00 to 00:00)
    return if start_time.hour >= 23 && end_time.hour == 0

    if end_time <= start_time
      errors.add(:end_time, "must be after the start time")
    end
  end
end
