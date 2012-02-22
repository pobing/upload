class CreateFileVersions < ActiveRecord::Migration
  def self.up
    create_table :file_versions do |t|
      t.references :file
      t.integer :version_num
      t.string :digest
      t.integer :editor_id
      t.text :note
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :file_versions
  end
end

