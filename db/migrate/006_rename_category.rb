class RenameCategory < ActiveRecord::Migration
  def self.up
    rename_column :categories, :parent_category_id, :parent_id
  end

  def self.down
    rename_column :categories, :parent_id, :parent_category_id
  end
end
