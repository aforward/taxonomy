class UpdateCategories < ActiveRecord::Migration
  def self.up
    
    Category.delete_all
    
    Category.new({ :name => "Audio", :level => 0 }).save
    Category.new({ :name => "Clustering", :level => 0 }).save
    Category.new({ :name => "Communications", :level => 0 }).save
    Category.new({ :name => "Database", :level => 0 }).save
    Category.new({ :name => "Desktop", :level => 0 }).save
    Category.new({ :name => "Development Tools", :level => 0 }).save
    Category.new({ :name => "Distributions and Standards", :level => 0 }).save
    Category.new({ :name => "Education", :level => 0 }).save
    Category.new({ :name => "Enterprise", :level => 0 }).save
    Category.new({ :name => "Financial", :level => 0 }).save
    Category.new({ :name => "Games/Entertainment", :level => 0 }).save
    Category.new({ :name => "Graphics", :level => 0 }).save
    Category.new({ :name => "Hardware", :level => 0 }).save
    Category.new({ :name => "Information resources", :level => 0 }).save
    Category.new({ :name => "Linux", :level => 0 }).save
    Category.new({ :name => "Management and Business", :level => 0 }).save
    Category.new({ :name => "Miscellaneous", :level => 0 }).save
    Category.new({ :name => "Multimedia / Publishing", :level => 0 }).save
    Category.new({ :name => "Networking / Telecom", :level => 0 }).save
    Category.new({ :name => "Office/Business", :level => 0 }).save
    Category.new({ :name => "Operating Systems", :level => 0 }).save
    Category.new({ :name => "Plugin", :level => 0 }).save
    Category.new({ :name => "Printing", :level => 0 }).save
    Category.new({ :name => "Programming", :level => 0 }).save
    Category.new({ :name => "Religion", :level => 0 }).save
    Category.new({ :name => "Scientific / Engineering", :level => 0 }).save
    Category.new({ :name => "Security", :level => 0 }).save
    Category.new({ :name => "Sociology", :level => 0 }).save
    Category.new({ :name => "Storage", :level => 0 }).save
    Category.new({ :name => "Student", :level => 0 }).save
    Category.new({ :name => "System and Network Utilities", :level => 0 }).save
    Category.new({ :name => "Terminals", :level => 0 }).save
    Category.new({ :name => "Text Editors", :level => 0 }).save
    Category.new({ :name => "Utility", :level => 0 }).save
    Category.new({ :name => "Voice Over IP (VoIP)", :level => 0 }).save
    Category.new({ :name => "Web / Internet", :level => 0 }).save
    Category.new({ :name => "Windows", :level => 0 }).save
    Category.new({ :name => "XML", :level => 0 }).save
    
    
  end

  def self.down
  end
end



