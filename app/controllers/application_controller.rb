class ApplicationController < ActionController::Base
  include Pundit
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  use_growlyflash

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def find_burnrate
    @burnrate = Burnrate.find(params[:burnrate_id]).decorate
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:accept_invitation) do |u|
      u.permit(
        :password,
        :password_confirmation,
        :invitation_token,
        user_detail_attributes: [:first_name, :last_name, :phone])
    end
  end

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referrer || root_path)
  end
end
