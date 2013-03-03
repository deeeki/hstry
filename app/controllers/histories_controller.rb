class HistoriesController < ApplicationController
  before_action :require_login

  def index
    @histories = History.all
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
