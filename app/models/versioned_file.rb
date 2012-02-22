class VersionedFile < ActiveRecord::Base
  has_many :versions, :class_name=>"FileVersion", :foreign_key=>"file_id"
  belongs_to :container, :polymorphic => true

  def last_version
    versions.find_by_version_num(last_version_num)
  end

  def put_version(version_num, upload_file, digest, editor_id, note)
    digest_calc = VersionedFile.digest_upload_file(upload_file)
    raise "mismatched digest" if !digest.blank? and digest_calc != digest
    upload_file.rewind
    path = File.join(VersionedFile.get_path_by_digest(digest_calc))
    VersionedFile.write_file(path, upload_file)
    self.transaction do
      current_ver = self.last_version_num
      current_ver = 0 if current_ver == nil
      raise "changed by someone else during editing" if current_ver+1 != version_num
      FileVersion.create! :file_id=>self.id, :version_num=>version_num, :digest=>digest_calc, :editor_id=>editor_id, :note=>note
      self.last_version_num = version_num
      save!
    end
  end

  def get_version_filename(version_num)
    VersionedFile.get_path_by_digest(self.versions.find_by_version_num(version_num).digest)
  end

private
  def self.get_path_by_digest(digest)
    directory = "files"
    File.join(directory, digest[0..1], digest[2..-1])
  end

  # 计算文件的md5值
  def self.digest_upload_file(upload_file)
    md5 = Digest::MD5.new
    while (buffer = upload_file.read(1024*1024))
      md5.update(buffer)
    end
    md5.hexdigest
  end

  def self.write_file(path, upload_file)
    return if File.exists?(path)
    dirname = File.dirname(path)
    FileUtils.mkdir_p(dirname) unless Dir.exists?(dirname)
    tmp_path = path + ".t"
    File.chmod(0222, tmp_path) if File.exists?(tmp_path)
    File.open(tmp_path, 'wb') do |f|
      while (buffer = upload_file.read(1024*1024))
        f.write(buffer)
      end
    end
    if File.exists?(path)
      FileUtils.rm(tmp_path)
    else
      File.chmod(0444, tmp_path)
      # 设置文件为只读属性
      FileUtils.mv(tmp_path, path)
    end
  end
end

