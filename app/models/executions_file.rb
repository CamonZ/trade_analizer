class ExecutionsFile < ActiveRecord::Base
  mount_uploader :file, ExecutionsFileUploader
end
