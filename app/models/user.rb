class User < ActiveRecord::Base
  
  has_many :personal_categories, :order => 'name ASC'
  attr_accessor :copy_type
  
  def validate        
    errors.add(:status,"must be inprogress, complete, or withdrawn; not #{status}") unless ['inprogress','complete','withdrawn'].include?(status)
  end
  
  def before_save
    self.email = 'anonymous' if anonymous?
    @apply_categories = new_record?
    self.password = User.new_password if @apply_categories
  end
  
  def after_save
    return unless @apply_categories
  
    if $application_mode == "modify_latest"
      Category.assign_latest_to(self)
    elsif $application_mode == "create_new"
      all_categories = Category.find(:all)
      
      new_categories_length = rand(4).to_i + 4
      
      if all_categories.length <= new_categories_length
        all_categories.each do |category|
          save_personal_category category
        end
      else
        for i in 1..new_categories_length
          next_index = rand(all_categories.length)
          save_personal_category all_categories[next_index]
          all_categories.delete_at next_index
        end
      end
    end
  end

  def User.authenticate(email, password)
    User.find_by_email_and_password(email,password)
  end

  def anonymous?
    myemail = self[:email]
    myemail.nil? or myemail == '' or self[:email] == 'anonymous'
  end
  
  def admin?
    self.status == 'admin'
  end
  
  def organized_categories
    PersonalCategory.find_all_by_user_id_and_level_and_status(id,FIRST_LEVEL,"assigned",:order => "name asc")
  end
  
  def User.new_password(size = 4)
    chars = (('a'..'z').to_a + ('0'..'9').to_a) - %w(i o 0 1 l 0)
    (1..size).collect{|a| chars[rand(chars.size)] }.join
  end
  
  private
  
    def assign_children_to(parent)
      children = Hash.new
      personal_categories.each do |possible_child|
        children[possible_child] = assign_children_to(possible_child) if possible_child.parent_id == parent.id and possible_child.status == 'assigned'
      end
      children
    end
    
    def save_personal_category category
      personal_category = PersonalCategory.new
      personal_category.name = category.name
      personal_category.level = category.level
      personal_category.category_id = category.id
      personal_category.user_id = id
      personal_category.status = 'unassigned'
      personal_category.save
    end

#    def organized_categories
#      organized = Hash.new
#      personal_categories.each do |category|
#        organized[category] = assign_children_to(category) if category.level == FIRST_LEVEL and category.status == 'assigned'
#      end
#      organized
#    end

  
  
end
