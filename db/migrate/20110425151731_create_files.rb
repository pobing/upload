class CreateFiles < ActiveRecord::Migration
  def self.up
    create_table "versioned_files" do |t|
      t.string :uuid # 文件唯一标识
      t.integer :last_version_num # 最后版本号
      t.references :container, :polymorphic => true
      t.string  :filename, :null=>false # 文件名称或者wiki标题
      t.string  :mime_type # 支持html(默认类型)/word/excel/powerpoint/wps文字/wps表格等类型
      t.integer :author_id # 原始作者(第一版作者)
      t.boolean :locked # 锁定标志: NULL-继承container的锁, 0-不锁定, 1-锁定
      t.integer :downloads # 下载次数
      t.string  :description # 文件说明
      t.boolean :deleted
      t.timestamps
    end
  end

  def self.down
    drop_table "versioned_files"
  end
end

