class DashboardController < ApplicationController
  respond_to :html, :json
  def index
    @dashboard = Dashboard.first
  end
  
  def upload
    @dashboard = Dashboard.first
    @dashboard.load_executions(params[:executions].tempfile, params[:executions].original_filename)
    
    respond_to do |format|
      format.html { redirect_to root_path}
    end
    
  end

  def statistics
    @dashboard = Dashboard.first
    if @dashboard.profit_and_loss_statistics.size > 0
      res = @dashboard.profit_and_loss_statistics.weekly.first.statistics_to_json
    else
      res = {:statistics => {}}
    end
    
    respond_with(res)
  end
end
