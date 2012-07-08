class ExecutionsController < ApplicationController
  def index
    @executions_file = ExecutionsFile.new
  end
  
  def upload
    debugger
    logger.debug params
  end
end
