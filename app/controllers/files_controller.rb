class FilesController < ApplicationController
  def version
    get_version if request.get?
    put_version if request.post?
  end

  private
  def get_version
    vfile = VersionedFile.find_by_uuid(params["id"])
    send_file vfile.get_version_filename(params["version"]), :filename=>vfile.filename, :type=>vfile.mime_type, :x_sendfile=>true
  end

  def put_version
    vfile = VersionedFile.find_by_uuid(params["id"])
    vfile.put_version params["version"].to_i, params["file"], params["digest"], params["editor"].to_i, params["note"]
    render :action=>"put_version"
  end
end

