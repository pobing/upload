class FileVersion < ActiveRecord::Base
  belongs_to :file, :class_name=>"VersionedFile", :foreign_key=>"file_id"
end

