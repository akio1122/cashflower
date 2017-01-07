class Users::RegistrationsController < DeviseInvitable::RegistrationsController
  prepend_before_action :require_no_authentication, only: [:new, :create, :cancel]
  prepend_before_action :authenticate_scope!, only: [:edit, :update, :destroy]
  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:email, :password, :password_confirmation,
               user_detail_attributes: [:first_name, :last_name, :company_name])
    end
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.permit(:email, :current_password, :password, :password_confirmation,
               user_detail_attributes: [:first_name, :last_name, :company_name])
    end
  end

  # The path used after sign up.
  def after_sign_up_path_for(_resource)
    portfolios_path(show_welcome: true)
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
