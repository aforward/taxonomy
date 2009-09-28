class CreateCategories < ActiveRecord::Migration
  def self.up
    create_table :categories do |t|
      t.column :name, :string
      t.column :level, :int
      t.column :status, :string, :default => 'unassigned'
      t.column :parent_category_id, :int
    end
    
    Category.new({ :name => "Desktop productivity", :level => 0 }).save
    Category.new({ :name => "Development tools", :level => 0 }).save
    Category.new({ :name => "Educational", :level => 0 }).save
    Category.new({ :name => "Entertainment", :level => 0 }).save
    Category.new({ :name => "Information resources", :level => 0 }).save
    Category.new({ :name => "Management and Business", :level => 0 }).save
    Category.new({ :name => "Math / Stats / Data analysis", :level => 0 }).save
    Category.new({ :name => "Misc", :level => 0 }).save
    Category.new({ :name => "Multimedia / publishing", :level => 0 }).save
    Category.new({ :name => "Networking / Telecom", :level => 0 }).save
    Category.new({ :name => "Operating Systems & Hardware support", :level => 0 }).save
    Category.new({ :name => "Web / Internet", :level => 0 }).save
    
    Category.new({ :name => "Acrobat/PDF Utilities", :level => 0 }).save
    Category.new({ :name => "Browsers", :level => 0 }).save
    Category.new({ :name => "Communication and E-mail software", :level => 0 }).save
    Category.new({ :name => "Contact/Content Management", :level => 0 }).save
    Category.new({ :name => "Spreadsheet Software", :level => 0 }).save
    Category.new({ :name => "Time Management", :level => 0 }).save
    Category.new({ :name => "Word Processing", :level => 0 }).save
    Category.new({ :name => "Database", :level => 0 }).save
    Category.new({ :name => "Development", :level => 0 }).save
    Category.new({ :name => "Reporting", :level => 0 }).save
    Category.new({ :name => "Design Tools", :level => 0 }).save
    Category.new({ :name => "Accounting Software", :level => 0 }).save
    Category.new({ :name => "Administration/Management", :level => 0 }).save
    Category.new({ :name => "Business & Productivity", :level => 0 }).save
    Category.new({ :name => "Business and Finance", :level => 0 }).save
    Category.new({ :name => "Finance/Accounting/Tax", :level => 0 }).save
    Category.new({ :name => "HR Management", :level => 0 }).save
    Category.new({ :name => "Money Management", :level => 0 }).save
    Category.new({ :name => "Project Management", :level => 0 }).save
    Category.new({ :name => "Data Analysis and Reporting", :level => 0 }).save
    Category.new({ :name => "Mathematics", :level => 0 }).save
    Category.new({ :name => "Statistical software", :level => 0 }).save
    Category.new({ :name => "Applications", :level => 0 }).save
    Category.new({ :name => "Miscellaneous software", :level => 0 }).save
    Category.new({ :name => "Science and Engineering", :level => 0 }).save
    Category.new({ :name => "3D Designing/Modeling", :level => 0 }).save
    Category.new({ :name => "3D Multimedia Presentation", :level => 0 }).save
    Category.new({ :name => "Audio & Video Software", :level => 0 }).save
    Category.new({ :name => "Desktop Publishing", :level => 0 }).save
    Category.new({ :name => "Graphics Software", :level => 0 }).save
    Category.new({ :name => "Multimedia & Design", :level => 0 }).save
    Category.new({ :name => "Publishing", :level => 0 }).save
    Category.new({ :name => "Video Editing", :level => 0 }).save
    Category.new({ :name => "Surveillance", :level => 0 }).save
    Category.new({ :name => "Recognition", :level => 0 }).save
    Category.new({ :name => "acd systems", :level => 0 }).save
    Category.new({ :name => "Networking (FTP, IP file sharing)", :level => 0 }).save
    Category.new({ :name => "Accessibility", :level => 0 }).save
    Category.new({ :name => "Add on/Application", :level => 0 }).save
    Category.new({ :name => "Add on/Symbols/Plugin", :level => 0 }).save
    Category.new({ :name => "Operating Systems", :level => 0 }).save
    Category.new({ :name => "Printing", :level => 0 }).save
    Category.new({ :name => "Security & Privacy & Spyware", :level => 0 }).save
    Category.new({ :name => "Emulation", :level => 0 }).save
    Category.new({ :name => "Fonts", :level => 0 }).save
    Category.new({ :name => "Mobile", :level => 0 }).save
    Category.new({ :name => "Desktop Enhancements", :level => 0 }).save
    Category.new({ :name => "Diagnostic", :level => 0 }).save
    Category.new({ :name => "Drivers/Firmware", :level => 0 }).save
    Category.new({ :name => "Anti-Virus, Anti-Spam, Anti-Spyware software", :level => 0 }).save
    Category.new({ :name => "Apple Hardware", :level => 0 }).save
    Category.new({ :name => "Backup, Recovery, Storage", :level => 0 }).save
    Category.new({ :name => "Server Utilities", :level => 0 }).save
    Category.new({ :name => "Wireless Utilities", :level => 0 }).save
    Category.new({ :name => "E-Commerce", :level => 0 }).save
    Category.new({ :name => "Internet", :level => 0 }).save
    Category.new({ :name => "Web Applications", :level => 0 }).save
    Category.new({ :name => "Web Authoring / Publishing Software", :level => 0 }).save
    Category.new({ :name => "Web Software & Development", :level => 0 }).save
    Category.new({ :name => "Utilities", :level => 0 }).save
    Category.new({ :name => "Languages (Spoken / Written)", :level => 0 }).save
    Category.new({ :name => "Libraries", :level => 0 }).save
    Category.new({ :name => "Maps & Travelling", :level => 0 }).save
    Category.new({ :name => "Action & Adventure", :level => 0 }).save
    Category.new({ :name => "Arcade", :level => 0 }).save
    Category.new({ :name => "Game/Entertainment", :level => 0 }).save
    Category.new({ :name => "Education, Learning and Reference", :level => 0 }).save
    Category.new({ :name => "Home & Education", :level => 0 }).save
    Category.new({ :name => "Training Software", :level => 0 }).save
    Category.new({ :name => "Developer / Development Tools", :level => 0 }).save
    Category.new({ :name => "Documentation", :level => 0 }).save
    Category.new({ :name => "Modeling", :level => 0 }).save
    
  end

  def self.down
    drop_table :categories
  end
end
