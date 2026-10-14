module Admin
  class UsersController < ApplicationController
    before_action :authenticate_admin!

    def index
      @users = User.order(created_at: :desc)
    end

    def destroy
      @user = User.find(params[:id])
      if @user == @current_user
        redirect_to admin_users_path, alert: "No puedes eliminarte a ti mismo."
      else
        @user.destroy
        redirect_to admin_users_path, notice: "El usuario fue eliminado."
      end
    end
  end
end
