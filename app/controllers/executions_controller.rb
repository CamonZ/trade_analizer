class ExecutionsController < ApplicationController
  def index
    @ef = ExecutionsFile.new
    @executions = ExecutionsFile.all
  end
  
  def upload
    @executions_file = ExecutionsFile.new
    
    result = @executions_file.parse()
  end
end
