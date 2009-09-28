class TaxonomyController < ApplicationController

  before_filter :check_authentication, :except => :latest
  before_filter :update_modify_latest
  verify :method => "post", :except => [ :index, :build, :evaluate, :list, :latest ], :text => ''

  def update_modify_latest
    @modify_latest = params[:modify_latest]
  end
  
  def latest
    @latest_categories = Category.latest
  end
  
  def publish
    @lookup_user = User.find_by_id(params[:lookup]) if @user.admin? and !params[:lookup].nil?
    redirect_to(:action => 'build') and return if @lookup_user.nil?
    
    Category.publish(@lookup_user)
    redirect_to(:action => 'latest')
  end

  def assign
  
  end

  def build
    @lookup_user = @user
    @lookup_user = User.find_by_id(params[:lookup]) if @user.admin? and !params[:lookup].nil?

    redirect_to(:action => 'list') and return if @lookup_user.nil?    
    @unassigned_categories = PersonalCategory.find_all_by_user_id_and_status(@lookup_user.id,'unassigned')
    @organized_categories = @lookup_user.organized_categories
    @read_only = false
    @modify_latest = false
  end
  
  def evaluate
    build
    @modify_latest = true
  end
  
  def list
    redirect_to(:controller => 'taxonomy', :action => 'build') if !@user.admin?
    @all_users = User.find_all_by_status('complete')
  end
  
  def create_category
    parent_id = params[:parent_id]
    level = parent_id.nil? ? FIRST_LEVEL : PersonalCategory.find_by_id(parent_id).level + 1
    name = params[:personal_category][:name]
    add_category_to parent_id, level, name
  end

  def assign_category
    parent_id = params[:parent_id]
    child_id = params[:id].split('_')[3] || params[:id].split('_')[1]
    new_child_category = PersonalCategory.find_by_id(child_id)
    
    if new_child_category.nil?
      render :text => "Unknown child id #{child_id}"
      return
    end
    
    was_assigned = new_child_category.status == 'assigned'
    parent_category = parent_id.nil? ? PersonalCategory.new : PersonalCategory.find_by_id(parent_id)

    if parent_category.add_child! new_child_category
      if was_assigned and !parent_id.nil?
        @replace_category = parent_category
        replace_before = @replace_category.parent_id
      else
        @replace_category = new_child_category
        replace_before = parent_id
      end
      @category =  new_child_category
      @insert_before_row_id = insert_before_row_id_of(replace_before);
      my_action = was_assigned ? 'move_category.rjs' : 'assign_category.rjs'
      render :action => my_action
    else
      puts "damnit"
      render :text => "Unable to add #{parent_id} to #{child_id}"
    end
  end
  
  def create_unassigned_category
    
    new_name = params[:personal_category][:name]
    existing_category = PersonalCategory.find_by_name_and_user_id(new_name,@user.id)
    
    if existing_category
      
      old_name = existing_category.name
      existing_category.name = new_name and existing_category.save! unless new_name == old_name
    
      @category = existing_category
      desired_action = existing_category.status == 'assigned' ? 'show_category.rjs' : 'show_unassigned_category.rjs'
      render :action => desired_action
      return
    end
    
    @category = PersonalCategory.new(params[:personal_category])
    @category.level = FIRST_LEVEL
    @category.user = @user
    @category.status = 'unassigned'
    
    if (@category.save)
      render :action => 'create_unassigned_category.rjs'
    else
      render :text => 'testme'
    end
  end
  
  def remove_category
    @category = PersonalCategory.find_by_id(params[:id])
    if @category.status == 'deleted'
      render :text => ''
      return
    end
    is_assigned = @category.status == 'assigned'
    if @category.remove!
      if is_assigned
        render :action => 'remove_category.rjs'
      else
        render :action => 'remove_unassigned_category.rjs'
      end
    else  
      render :text => 'testme'
    end
  end

  protected  
  
    def assign_category_to(category,user,level,parent_id)
      category.user = user
      category.level = level
      category.parent_id = parent_id
      category.status = 'assigned'
      category
    end  
    
    def insert_before_row_id_of(parent_id)
      parent_id.nil? ? "displaycategory" : "newcategory#{parent_id}"
    end

    def add_category_to(parent_id, level, name)
      render :text => "" and return unless request.post?
      existing_category = PersonalCategory.find_by_name_and_user_id(name,@user.id)
      @insert_before_row_id = insert_before_row_id_of(parent_id)
      
      unless existing_category.nil?
        
        real_name = existing_category.name
        existing_category.name = name and existing_category.save unless real_name == name
        
        @category = existing_category
        if existing_category.status == 'assigned'
          @parent_id = parent_id
          render :action => 'show_category.rjs'
        else
          existing_category = assign_category_to(existing_category,@user,level,parent_id)
          if existing_category.save
            render :action => 'assign_category.rjs'
          else
            render :text => ''
          end
        end
        return      
      end
      
      @category = assign_category_to(PersonalCategory.new(params[:personal_category]),@user,level,parent_id)
      if @category.save
        render :action => 'create_category.rjs'
      else
        render :text => ""
      end    
    end
end