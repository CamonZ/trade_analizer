class ExecutionsController < ApplicationController
  def index
    @ef = ExecutionsDay.new
    @executions = ExecutionsDay.by_date
  end
  
  def show
    @executions_file = ExecutionsDay.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def upload
    @executions_day = ExecutionsDay.new

    @executions_day.parse(params[:executions_day][:file].tempfile, params[:executions_day][:file].original_filename)
    
    respond_to do |format|
      format.html { redirect_to root_path}
    end
  end
end
