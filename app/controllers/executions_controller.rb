class ExecutionsController < ApplicationController
  def index
    @ef = ExecutionsFile.new
    @executions = ExecutionsFile.all
  end
  
  def show
    @executions_file = ExecutionsFile.find(params[:id])
    
    respond_to do |format|
      format.html
    end
  end
  
  def upload
    @executions_file = ExecutionsFile.new

    @executions_file.parse(params[:executions_file][:file].tempfile, params[:executions_file][:file].original_filename)
    
    respond_to do |format|
      format.html { redirect_to root_path}
    end
  end
end
