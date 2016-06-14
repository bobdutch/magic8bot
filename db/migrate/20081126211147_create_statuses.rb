class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.datetime :created_at
      t.string :profile_image_url
      t.string :from_user
      t.integer :to_user_id
      t.string :text
      t.column :status_id, :"int (12) unsigned"
      t.integer :from_user_id
      t.string :to_user
      t.string :iso_language_code
      t.column :in_reply_to_status_id, :"int (12) unsigned"
      t.string :type
      t.boolean :answered
    end
  end

  def self.down
    drop_table :statuses
  end
end
