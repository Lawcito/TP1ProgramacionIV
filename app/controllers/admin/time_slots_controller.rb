module Admin
  class TimeSlotsController < ApplicationController
    before_action :authenticate_admin!

    def index
      @time_slots = TimeSlot.order(:day_of_week, :start_time)
      @time_slot = TimeSlot.new
    end

    def new
      @time_slot = TimeSlot.new
    end

    def create
      @time_slot = TimeSlot.new(time_slot_params)
      if @time_slot.save
        redirect_to admin_time_slots_path, notice: "Horario creado exitosamente."
      else
        @time_slots = TimeSlot.order(:day_of_week, :start_time)
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @time_slot = TimeSlot.find(params[:id])
      @time_slot.destroy
      redirect_to admin_time_slots_path, notice: "Horario eliminado exitosamente."
    end

    private

    def time_slot_params
      params.require(:time_slot).permit(:day_of_week, :start_time, :end_time)
    end
  end
end
