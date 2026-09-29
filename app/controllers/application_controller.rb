class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def authenticate_api_request!
    header = request.headers['Authorization']
    token = header.split(' ').last if header
    begin
      decoded = JWT.decode(token, Rails.application.secret_key_base)[0]
      @current_user = User.find(decoded['user_id'])
    rescue ActiveRecord::RecordNotFound, JWT::DecodeError
      render json: { error: 'Unauthorized. Token missing or invalid.' }, status: :unauthorized
    end
  end

  def authenticate_admin!
    authenticate_or_request_with_http_basic("Admin Back-office") do |email, password|
      user = User.find_by(email: email)
      user && user.authenticate(password) && user.admin?
    end
  end
end
