module Admin
  class CourtsController < ApplicationController
    before_action :authenticate_admin!
    
    def index
      @courts = Court.all
    end

    def new
      @court = Court.new
    end

    def create
      @court = Court.new(court_params)
      if @court.save
        redirect_to admin_courts_path, notice: 'La cancha fue creada exitosamente.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @court = Court.find(params[:id])
      @court.destroy
      redirect_to admin_courts_path, notice: 'La cancha fue eliminada.'
    end

    private

    def court_params
      params.require(:court).permit(:name, :price, :covered)
    end
  end
end
