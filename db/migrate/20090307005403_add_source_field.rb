class AddSourceField < ActiveRecord::Migration
  def self.up
    add_column :statuses, :source, :string
  end

  def self.down
    remove_column :statuses, :source
  end
end
