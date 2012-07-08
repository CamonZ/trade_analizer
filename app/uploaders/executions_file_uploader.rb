# encoding: utf-8

class ExecutionsFileUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage :file


  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
    'txt'
  end
end
