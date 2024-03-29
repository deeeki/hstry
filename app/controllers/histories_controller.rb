class HistoriesController < ApplicationController
  before_action :require_login

  def index
    @authenticated_providers = current_user.authentications.pluck(:provider)
    @histories = current_user.histories
  end

  def create
    if current_user.fetch_histories(params[:provider])
      redirect_to :root, notice: 'Fetched successfully'
    else
      redirect_to :root, alert: 'Fail to fetch'
    end
  end

  def clear
    current_user.histories.destroy_all
    redirect_to :root, notice: 'Cleared successfully'
  end
end
