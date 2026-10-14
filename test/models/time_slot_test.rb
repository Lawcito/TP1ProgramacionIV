require "test_helper"

class TimeSlotTest < ActiveSupport::TestCase
  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------
  def valid_slot(start_h: 10, end_h: 11, day: 1)
    TimeSlot.new(
      day_of_week: day,
      start_time: Time.zone.parse("2000-01-01 #{start_h}:00:00"),
      end_time:   Time.zone.parse("2000-01-01 #{end_h}:00:00")
    )
  end

  # ---------------------------------------------------------------------------
  # Presence validations
  # ---------------------------------------------------------------------------
  test "is valid with all required attributes" do
    assert valid_slot.valid?
  end

  test "is invalid without day_of_week" do
    slot = valid_slot
    slot.day_of_week = nil
    assert_not slot.valid?
    assert_includes slot.errors[:day_of_week], "can't be blank"
  end

  test "is invalid without start_time" do
    slot = valid_slot
    slot.start_time = nil
    assert_not slot.valid?
    assert_includes slot.errors[:start_time], "can't be blank"
  end

  test "is invalid without end_time" do
    slot = valid_slot
    slot.end_time = nil
    assert_not slot.valid?
    assert_includes slot.errors[:end_time], "can't be blank"
  end

  # ---------------------------------------------------------------------------
  # Custom validation: end_time_after_start_time
  # ---------------------------------------------------------------------------
  test "is invalid when end_time is before start_time" do
    slot = valid_slot(start_h: 14, end_h: 13)
    assert_not slot.valid?
    assert_includes slot.errors[:end_time], "must be after the start time"
  end

  test "is invalid when end_time equals start_time" do
    slot = valid_slot(start_h: 10, end_h: 10)
    assert_not slot.valid?
    assert_includes slot.errors[:end_time], "must be after the start time"
  end

  test "is valid when end_time is after start_time" do
    slot = valid_slot(start_h: 10, end_h: 11)
    assert slot.valid?
  end

  test "allows midnight rollover (23:00 to 00:00)" do
    slot = TimeSlot.new(
      day_of_week: 1,
      start_time: Time.zone.parse("2000-01-01 23:00:00"),
      end_time:   Time.zone.parse("2000-01-01 00:00:00")
    )
    assert slot.valid?, "Midnight rollover slot should be valid. Errors: #{slot.errors.full_messages}"
  end

  # ---------------------------------------------------------------------------
  # Instance methods
  # ---------------------------------------------------------------------------
  test "#day_name returns Spanish name for weekday" do
    slot = time_slots(:slot_manana)   # day_of_week: 1 => Lunes
    assert_equal "Lunes", slot.day_name
  end

  test "#day_name returns fallback for unknown day" do
    slot = valid_slot(day: 99)
    assert_equal "Día 99", slot.day_name
  end

  test "#formatted_time_range returns HH:MM range string" do
    slot = time_slots(:slot_manana)
    result = slot.formatted_time_range
    assert_match(/\d{2}:\d{2} a \d{2}:\d{2} hs/, result)
  end

  test "#formatted_time_range handles nil times gracefully" do
    slot = TimeSlot.new
    result = slot.formatted_time_range
    assert_equal "--:-- a --:-- hs", result
  end

  # ---------------------------------------------------------------------------
  # Fixtures sanity
  # ---------------------------------------------------------------------------
  test "fixture slot_manana is on Monday from 10 to 11" do
    slot = time_slots(:slot_manana)
    assert_equal 1, slot.day_of_week
    assert_equal 10, slot.start_time.hour
    assert_equal 11, slot.end_time.hour
  end

  test "fixture slot_noche represents midnight rollover" do
    slot = time_slots(:slot_noche)
    assert_equal 23, slot.start_time.hour
    assert_equal 0,  slot.end_time.hour
  end
end
