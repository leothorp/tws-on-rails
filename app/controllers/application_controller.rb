class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :null_session
  before_filter :configure_permitted_parameters, if: :devise_controller?

  def with_timezone(zone, &block)
    Time.use_zone(zone, &block)
  end

  def use_new_styles
    @use_new_styles = true
  end

  rescue_from CanCan::AccessDenied do |exception|
    go_back(exception)
  end

  # Override Devise's after_sign_in_path_for to check whether
  # the user (here, `resource` would be User) has a stored
  # redirect location, and use that as the path. Otherwise,
  # go to a city page.
  # See https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  def after_sign_in_path_for(resource)
    redirect_path = stored_location_for(resource)
    if redirect_path
      redirect_path
    else
      tea_times_path
    end
  end

  protected

    def authorize_host!
      if @current_user && !@current_user.host?
        redirect_to hosting_path
      end
    end

    def away_non_user
      if !current_user
        redirect_to root_path, alert: 'Log in before trying that again :)'
      end
    end

    def away_ye_waitlisted
      if !current_user
        redirect_to root_path, alert: 'Log in before trying that again :)'
      elsif current_user && current_user.waitlisted?
        redirect_to root_path, alert: "We'll have something for you here when we get you off the wait list!"
      end
    end

    def go_back(exception)
      begin
        redirect_to :back, :alert => exception.message
      rescue ActionController::RedirectBackError
        redirect_to root_path
      end
    end

    def configure_permitted_parameters
      permitted = [:nickname, :family_name, :given_name, :email, :password,
                   :password_confirmation, :avatar, :current_password,
                   :tagline, :summary, :topics, :story, :home_city_id,
                   :facebook, :twitter, :phone_number, :commitment_overview,
                   :commitment_detail]
      [:sign_up, :account_update].each do |s|
        devise_parameter_sanitizer.permit(s) do |u|
          u.permit(*permitted)
        end
      end
    end

end
