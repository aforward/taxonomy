class CreatePersonalCategories < ActiveRecord::Migration
  def self.up
    create_table :personal_categories do |t|
      t.column :name, :string
      t.column :level, :int
      t.column :parent_id, :int
      t.column :user_id, :int
      t.column :category_id, :int
      t.column :status, :string, :default => 'unassigned'
    end
  end

  def self.down
    drop_table :personal_categories
  end
end
