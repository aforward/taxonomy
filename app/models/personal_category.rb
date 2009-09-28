class PersonalCategory < ActiveRecord::Base
  validates_presence_of :name, :level, :user_id
  validates_numericality_of :level
  
  belongs_to :user
  belongs_to :category
  
  def PersonalCategory.empty(name,level)
    c = PersonalCategory.new
    c.name = name
    c.level = level
    c
  end

  def validate        
    personal_category = PersonalCategory.find_by_name_and_level_and_user_id(name,level,user_id)
    errors.add_to_base("Duplicate name") unless personal_category.nil? or personal_category.id == id
    errors.add(:level,"must be between #{FIRST_LEVEL} and #{LAST_LEVEL}") unless !level.nil? and level >= FIRST_LEVEL and level <= LAST_LEVEL
    errors.add(:status,"must be assigned, unassigned, or deleted; not #{status}") unless ['assigned','unassigned','deleted'].include?(status)
    errors.add(:user_id,"unknown user") unless User.exists?(user_id)
    errors.add(:category_id,"unknown category") unless category_id.nil? or Category.exists?(category_id)
  end
  
  def prefix
    Category.calculate_prefix_for self
  end
  
  def add_child!(child_category)
    return false if self.level == LAST_LEVEL
    if self.new_record?
      PersonalCategory.add_root! child_category
    else
      self.status = 'assigned'
      save and update_child_levels_for self, child_category, false
    end
  end
  
  def PersonalCategory.add_root!(root_category)
    root_category.status = 'assigned'
    root_category.level = FIRST_LEVEL
    root_category.parent_id = nil
    root_category.save
  end
  
  def remove!
    children.each do |child|
      child.remove!
    end
    self.status = 'deleted'
    self.parent_id = nil
    save
  end
  
  def store_entire_structure!
    @internal_children = children
    @is_cached = true;
    @internal_children.each do |child|
      child.store_entire_structure!
    end
    self
  end

  def children
    return @internal_children if @is_cached
    return [] unless status == 'assigned'
    PersonalCategory.find_all_by_parent_id_and_status_and_user_id(id,'assigned',user_id,:order => "name asc")
  end
  
  def ==(object)
    return false if !object.kind_of?(PersonalCategory)
    self.id == object.id
  end
  
  protected
  
    def update_child_levels_for(parent,child,overwrite)
      child.status = 'assigned'
      child.level = parent.level + 1
      child.parent_id = parent.id
      child.user_id = parent.user_id
      if (overwrite)
        child.level = LAST_LEVEL
      elsif child.level < LAST_LEVEL
        parent = child
      else
        overwrite = true
      end
      return false if !child.save!
      child.children.each do |grandchild|
        return false if !update_child_levels_for(parent,grandchild,overwrite)
      end
      return true
    end
end
