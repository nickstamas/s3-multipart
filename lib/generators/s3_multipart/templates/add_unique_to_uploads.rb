class AddUniqueToUploads < ActiveRecord::Migration
  def change
    add_column :s3_multipart_uploads, :unique, :string
  end
end

