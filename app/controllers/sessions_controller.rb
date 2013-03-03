class SessionsController < ApplicationController
  before_action :require_login, only: [:index, :destroy]

  def index
    @authenticated_providers = current_user.authentications.pluck(:provider)
  end

  def new
    redirect_to root_url, alert: 'Already logged in' if current_user
  end

  def create
    if current_user
      current_user.add_authentication_from_omniauth(env['omniauth.auth'])
      redirect_to connections_url, notice: "Connected with #{env['omniauth.auth'].provider} succesfully"
    else
      @user = User.from_omniauth(env['omniauth.auth'])
      session[:user_id] = @user.id
      redirect_to root_url, notice: "Logged in with #{env['omniauth.auth'].provider} succesfully"
    end
  end

  def show
    redirect_to root_url, alert: params[:message]
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end
