class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user

  private

  def current_user
    User.find(session[:user_id]) if session[:user_id]
  end

  def require_login
    redirect_to login_url, alert: 'Login required' unless current_user
  end
end
