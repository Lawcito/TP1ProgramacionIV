module Api
  module V1
    module Courts
      class TimeSlotsController < ApplicationController
        skip_before_action :verify_authenticity_token, raise: false

        # GET /api/v1/courts/:court_id/time_slots?date=YYYY-MM-DD
        def index
          court = Court.find(params[:court_id])

          date = begin
            Date.parse(params[:date])
          rescue ArgumentError, TypeError
            Date.current
          end

          # day_of_week: 0=Sunday Rails convention; model uses 1-7 Mon-Sun with 0 as alias for Sunday
          day_num = date.wday
          day_alias = day_num.zero? ? 7 : day_num

          time_slots = TimeSlot.where(day_of_week: [ day_num, day_alias ])
                               .order(:start_time)

          # Which slots are already taken for this court on this date?
          booked_ids = court.reservations
                            .where(date: date)
                            .where.not(status: :cancelled)
                            .pluck(:time_slot_id)
                            .to_set

          render json: time_slots.map { |slot|
            {
              id: slot.id,
              day_name: slot.day_name,
              start_time: slot.start_time.strftime("%H:%M"),
              end_time: slot.end_time.strftime("%H:%M"),
              formatted: slot.formatted_time_range,
              available: !booked_ids.include?(slot.id)
            }
          }, status: :ok
        end
      end
    end
  end
end

