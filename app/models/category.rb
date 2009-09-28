class Category < ActiveRecord::Base
  
  validates_presence_of :name, :level
  validates_numericality_of :level

  

  def validate
    errors.add(:level,"must be between #{FIRST_LEVEL} and #{LAST_LEVEL}") unless !level.nil? and level >= FIRST_LEVEL and level <= LAST_LEVEL
    errors.add(:status,"must be assigned, unassigned, or deleted; not #{status}") unless ['assigned','unassigned','deleted'].include?(status)
   
    category = Category.find_by_name_and_level(name,level)
    errors.add_to_base("Duplicate name") unless category.nil? or category.id == id
  end

  def prefix
    Category.calculate_prefix_for self
  end

  def children
    return [] unless status == 'assigned'
    Category.find_all_by_parent_id_and_status(id,'assigned',:order => "name asc")
  end
  
  def Category.latest
    Category.find_all_by_level_and_status(FIRST_LEVEL,'assigned',:order => "name asc")
  end

  def Category.publish(user)
    Category.find(:all).each do |category|
      category.status = "deleted"
      category.save!
    end
    
    user.personal_categories.each do |personal_category|
      if personal_category.status == "assigned" and personal_category.level == FIRST_LEVEL
        personal_category.store_entire_structure!
        Category.save_category personal_category, Category.new 
      end
    end
    
  end
  
  def Category.assign_latest_to(user)
    PersonalCategory.find_all_by_user_id(user.id).each do |personal_category|
      personal_category.status = "deleted"
      personal_category.save!
    end  
  
    PersonalCategory.delete_all("user_id = #{user.id}")
    @unorganized_categories = Category. find_all_by_status("assigned",:order => 'level asc')
    @unorganized_categories.each do |category|
      Category.save_personal_category category, user
    end    
  end


  def Category.calculate_prefix_for(category)
    answer = "C"
    category.level.times do
      answer = "S#{answer}"
    end
    answer  
  end

  private
  
    def Category.assign_children_to(parent)
      children = Hash.new
      @unorganized_categories.each do |possible_child|
        children[possible_child] = assign_children_to(possible_child) if possible_child.parent_id == parent.id and possible_child.status == 'assigned'
      end
      children
    end
    
    def Category.save_category personal_category, parent_category
      category = Category.find_by_name(personal_category.name) || Category.new
      category.name = personal_category.name
      category.level = personal_category.level
      category.status = 'assigned'
      category.parent_id = parent_category.id
      category.save
      
      personal_category.children.each do |child|
        Category.save_category child, category
      end
    end
    
    def Category.save_personal_category category, user
      personal_category = PersonalCategory.find_by_name_and_user_id(category.name,user.id) || PersonalCategory.new
      parent_personal_category = PersonalCategory.find_by_category_id_and_user_id(category.parent_id,user.id) || PersonalCategory.new
      personal_category.name = category.name
      personal_category.level = category.level
      personal_category.parent_id = parent_personal_category.id
      personal_category.category_id = category.id
      personal_category.user_id = user.id
      personal_category.status = category.status
      personal_category.save
    end    

#    def organized_categories    
#      organized = Hash.new
#      @unorganized_categories = Category. find_all_by_status("assigned", :order => "name asc")
#      @unorganized_categories.each do |category|
#        organized[category] = assign_children_to(category) if category.level == FIRST_LEVEL
#      end
#      organized
#    end  

    
end
