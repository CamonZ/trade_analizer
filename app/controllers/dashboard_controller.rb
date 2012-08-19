class DashboardController < ApplicationController
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
end
