class UpdateDemographics < ActiveRecord::Migration
  def self.up
    add_column :users, :years_experience, :string
    add_column :users, :education, :string
    add_column :users, :country, :string
  end

  def self.down
    remove_column :users, :years_experience
    remove_column :users, :education
    remove_column :users, :country
  end
end
