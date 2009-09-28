require File.dirname(__FILE__) + '/../test_helper'
require 'taxonomy_controller'
require 'welcome_controller'

# Re-raise errors caught by the controller.
class TaxonomyController; def rescue_action(e) raise e end; end

class TaxonomyControllerTest < Test::Unit::TestCase
  fixtures :personal_categories
  fixtures :categories
  fixtures :users

  def setup
    @controller = TaxonomyController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:anonymous1).id
    
    @mydevtools = personal_categories(:mydevtools)
    @myplugin = personal_categories(:myplugin)
    @mycodesnippets = personal_categories(:mycodesnippets)
    
  end

  def test_view_latest_without_being_logged_in
    @request.session[:user] = nil
    get :latest
    assert_response :success
  end  

  def test_view_latest
    get :latest
    assert assigns(:latest_categories)
  end

  
  def test_check_authentication_not_logged_in
    @request.session[:user] = nil
    get :build
    
    assert_response :redirect
    assert_redirected_to :controller => 'welcome', :action => 'intro'
    assert_equal 'taxonomy', @request.session[:intended_controller]
    assert_equal 'build', @request.session[:intended_action]
  end  

  def test_not_admin_looking_up_another_user
    @request.session[:user] = users(:james).id
    get :build, :lookup => users(:anonymous1).id
    assert_equal users(:james).id, assigns(:lookup_user).id
  end

  def test_admin_unknown_user_id
    @request.session[:user] = users(:admin).id
    get :build, :lookup => -2
    assert_redirected_to :controller => 'taxonomy', :action => 'list'
  end

  def test_list_not_admin
    @request.session[:user] = users(:james).id
    get :list
    assert_redirected_to :controller => 'taxonomy', :action => 'build'
  end

  def test_list_admin
    @request.session[:user] = users(:admin).id
    get :list
    assert assigns(:all_users)
    assert_equal 0, assigns(:all_users).length
    
    user = users(:james)
    user.status = 'complete'
    assert user.save!
    
    get :list
    assert_equal 1, assigns(:all_users).length
    
  end


  def test_build_assigns_categories
    get :build
    assert_response :success
    assert_template 'build'
    assert assigns(:unassigned_categories)
  end
  
  def test_build
   
    personal_categories(:mydevtools).status = 'assigned'
    assert personal_categories(:mydevtools).save

    get :build
    assert_response :success
    assert_template 'build'
    assert assigns(:unassigned_categories)
    assert assigns(:organized_categories)

    assert 2, assigns(:unassigned_categories).length
    assert 1, assigns(:organized_categories).length
    
  end
  
  def test_post_create_category

    num_categories = PersonalCategory.count

    post :create_category, :personal_category => {:name => "newname"}, :parent_id => nil
    assert_response :success
    assert_equal "newname", assigns(:category).name
    assert_equal FIRST_LEVEL, assigns(:category).level
    assert_equal 'assigned', assigns(:category).status
    assert_equal 'displaycategory', assigns(:insert_before_row_id)
    
    assert_equal users(:anonymous1).id, assigns(:category).user_id
    assert !assigns(:category).new_record?
    assert_equal num_categories + 1, PersonalCategory.count
    assert_template 'create_category.rjs'
    
  end
  
  def test_post_create_category_existing_and_assigned

    personal_categories(:mydevtools).status = 'assigned'
    assert personal_categories(:mydevtools).save
    num_categories = PersonalCategory.count

    post :create_category, :personal_category => {:name => "Development tools"}, :parent_id => nil
    assert_response :success
    assert_equal "Development tools", assigns(:category).name
    assert_equal num_categories, PersonalCategory.count
    assert_equal personal_categories(:mydevtools).id, assigns(:category).id
 
    assert_template 'show_category.rjs'
    
  end

  def test_post_create_category_existing_and_assigned_update_case

    personal_categories(:mydevtools).status = 'assigned'
    assert personal_categories(:mydevtools).save
    num_categories = PersonalCategory.count

    post :create_category, :personal_category => {:name => "Development Tools"}, :parent_id => nil
    assert_response :success
    assert_equal "Development Tools", assigns(:category).name
    assert_equal num_categories, PersonalCategory.count
    assert_equal personal_categories(:mydevtools).id, assigns(:category).id
    
    same = PersonalCategory.find_by_name('development tools')
    assert_equal 'Development Tools', same.name
 
    assert_template 'show_category.rjs'
    
  end


  def test_post_create_category_existing_and_assigned_sets_parent_id
    myplugin = personal_categories(:myplugin)
    

    myplugin.status = 'assigned'
    assert myplugin.save
    num_categories = PersonalCategory.count

    post :create_category, :personal_category => {:name => myplugin.name}, :parent_id => personal_categories(:mycodesnippets).id
    assert_response :success
    assert_equal personal_categories(:mycodesnippets).id.to_s, assigns(:parent_id)
    
  end
  
  def test_post_create_category_sets_newcategory_as_row_before
    devtools = personal_categories(:mydevtools)
    
    post :create_category, :personal_category => {:name => "newsub"}, :parent_id => devtools.id
    assert_response :success
    assert_template 'create_category.rjs'
    assert_equal "newcategory#{devtools.id}", assigns(:insert_before_row_id)
  end

  def test_assign_create_category_move_category
    assert @myplugin.add_child!(@mycodesnippets)

    post :assign_category, :id => "category_#{@myplugin.id}", :parent_id => @mydevtools.id, :modify_latest => true
    assert_response :success
    assert_template 'move_category.rjs'
    assert_equal "displaycategory", assigns(:insert_before_row_id)
    assert_equal @myplugin, assigns(:category)
    assert_equal @mydevtools, assigns(:replace_category)
  end


  def test_post_create_category_insert_before_row_id_when_no_parent

    post :create_category, :personal_category => {:name => @mydevtools.name}, :parent_id => nil
    assert_response :success
    assert_template 'assign_category.rjs'  
    assert_equal "displaycategory", assigns(:insert_before_row_id)
    assert_equal @mydevtools, assigns(:category)
  end
  
  def test_post_create_category_insert_before_row_id_when_has_parent

    mydevtools = personal_categories(:mydevtools)
    myplugin = personal_categories(:myplugin)

    post :assign_category, :id => "div_unassigned_category_#{myplugin.id}", :parent_id => mydevtools.id
    assert_response :success
    assert_template 'assign_category.rjs'
    assert_equal "newcategory#{mydevtools.id}", assigns(:insert_before_row_id)
  end    
  
  def test_post_create_catgory_unassigned_becomes_assigned
    num_categories = PersonalCategory.count
    devtools = personal_categories(:mydevtools)
    devtools.status = 'unassigned'
    devtools.level = 2
    assert personal_categories(:mydevtools).save

    post :create_category, :personal_category => {:name => devtools.name}, :parent_id => nil
    assert_response :success
    assert_equal "Development tools", assigns(:category).name
    assert_equal num_categories, PersonalCategory.count
    assert_equal personal_categories(:mydevtools).id, assigns(:category).id
    assert_equal 'assigned', assigns(:category).status 
    assert_template 'assign_category.rjs'  
  end

  def test_post_create_subcategory

    num_categories = PersonalCategory.count
    devtools = personal_categories(:mydevtools)
    
    post :create_category, :personal_category => {:name => "newsub"}, :parent_id => devtools.id
    assert_response :success
    assert_equal "newsub", assigns(:category).name
    assert_equal 1, assigns(:category).level
    assert_equal 'assigned', assigns(:category).status
    assert_equal devtools.id, assigns(:category).parent_id
    
    assert_equal users(:anonymous1).id, assigns(:category).user_id
    assert !assigns(:category).new_record?
    assert_equal num_categories + 1, PersonalCategory.count
    assert_template 'create_category.rjs'
    
  end

  def test_post_create_examplecategory

    num_categories = PersonalCategory.count
    myplugin = personal_categories(:myplugin)
    
    post :create_category, :personal_category => {:name => "newexample"}, :parent_id => myplugin.id
    assert_response :success
    assert_equal "newexample", assigns(:category).name
    assert_equal 2, assigns(:category).level
    assert_equal 'assigned', assigns(:category).status
    assert_equal myplugin.id, assigns(:category).parent_id
    
    assert_equal users(:anonymous1).id, assigns(:category).user_id
    assert !assigns(:category).new_record?
    assert_equal num_categories + 1, PersonalCategory.count
    assert_template 'create_category.rjs'
    
  end
  
  def test_logged_in_creates_user
    get :organize
    assert assigns(:user)
  end

  def test_unknown_user_id
    @request.session[:user] = -2
    get :build
    assert @request.session[:user].nil?
    assert_response :redirect
    assert_redirected_to :controller => 'welcome', :action => 'intro'
  end  
  
  def test_post_assign_category_unassigned

    mydevtools = personal_categories(:mydevtools)
    myplugin = personal_categories(:myplugin)

    post :assign_category, :id => "div_unassigned_category_#{myplugin.id}", :parent_id => mydevtools.id
    assert_response :success
 
    myplugin = PersonalCategory.find_by_id(myplugin.id)
 
    assert_equal myplugin.parent_id, mydevtools.id
    assert_equal 'assigned', myplugin.status
    assert_equal myplugin.id, assigns(:category).id
    
    assert_template 'assign_category.rjs'
  end  
  
  def test_post_assign_category_already_assigned
    assert PersonalCategory.add_root!(@mydevtools)
    assert @myplugin.add_child!(@mycodesnippets)

    post :assign_category, :id => "category_#{@myplugin.id}", :parent_id => @mydevtools.id
    assert_response :success
    saved = PersonalCategory.find_by_id(@myplugin.id)
    assert_equal saved.parent_id, @mydevtools.id
  end  

  def test_post_assign_category_new_root
    assert PersonalCategory.add_root!(@mydevtools)
    assert @myplugin.add_child!(@mycodesnippets)

    post :assign_category, :id => "category_#{@myplugin.id}", :parent_id => nil
    assert_response :success
    saved = PersonalCategory.find_by_id(@myplugin.id)
    assert_equal nil, @myplugin.parent_id
  end  

  
  def test_post_create_unassigned_category
  
    post :create_unassigned_category, :personal_category => { :name => 'newcat'}
    assert_response :success
    assert_template 'create_unassigned_category.rjs'
    assert assigns(:category)
    
    newcat = PersonalCategory.find_by_name('newcat')
    
    assert !newcat.nil?
    assert newcat.id, assigns(:category).id
    assert_equal nil, newcat.parent_id
    assert_equal 'unassigned', newcat.status
    assert_equal FIRST_LEVEL, newcat.level
    assert_equal 'newcat', newcat.name
    assert_equal assigns(:user).id, newcat.user_id
  end

  def test_post_create_unassigned_category_existing_unassigned
    
    mydevtools = personal_categories(:mydevtools)
    
    post :create_unassigned_category, :personal_category => { :name => mydevtools.name}
    assert_response :success
    assert_template 'show_unassigned_category.rjs'
    assert assigns(:category)
    assert mydevtools.id, assigns(:category).id
  end

  def test_post_create_unassigned_category_existing_unassigned_update_case
    
    mydevtools = personal_categories(:mydevtools)
    
    post :create_unassigned_category, :personal_category => { :name => 'Development Tools'}
    assert_response :success
    assert_template 'show_unassigned_category.rjs'
    assert assigns(:category)
    assert mydevtools.id, assigns(:category).id
    
    same = PersonalCategory.find_by_name('development tools')
    assert_equal 'Development Tools', same.name
    
    
  end


  def test_post_create_unassigned_category_existing_assigned
    
    mydevtools = personal_categories(:mydevtools)
    mydevtools.status = 'assigned'
    assert mydevtools.save
    
    post :create_unassigned_category, :personal_category => { :name => mydevtools.name}
    assert_response :success
    assert_template 'show_category.rjs'
    assert assigns(:category)
    assert mydevtools.id, assigns(:category).id
  end


  def test_get_create_unassigned_category
    mydevtools = personal_categories(:mydevtools)
    get :create_unassigned_category, :personal_category => { :name => 'newcat'}
    assert_response 0
  end


  def test_post_remove_category_unassigned
    mydevtools = personal_categories(:mydevtools)
    
    post :remove_category, :id => mydevtools.id
    assert_response :success
    assert_template 'remove_unassigned_category.rjs'
    assert assigns(:category)
    assert mydevtools.id, assigns(:category).id
    assert 'deleted', assigns(:category).status
  end

  def test_post_remove_category_already_deleted
    mydevtools = personal_categories(:mydevtools)
    mydevtools.status = 'deleted'
    assert mydevtools.save

    post :remove_category, :id => mydevtools.id
    assert_response :success
    assert_template nil
  
  end

  def test_post_remove_category_assigned_level0
    mydevtools = personal_categories(:mydevtools)
    mydevtools.status = 'assigned'
    assert mydevtools.save
    
    post :remove_category, :id => mydevtools.id
    assert_response :success
    assert_template "remove_category.rjs"
    assert assigns(:category)
    assert mydevtools.id, assigns(:category).id
    assert 'deleted', assigns(:category).status
      
  
  end

  def test_publishing
    assert Category.find_all_by_status("deleted").length == 0
    
    @request.session[:user] = users(:admin).id
    post :publish, :lookup => users(:anonymous1).id
    assert_redirected_to :controller => 'taxonomy', :action => 'latest'
    
    assert Category.find_all_by_status("deleted").length > 0
  end

  def test_not_admin_publishing
    @request.session[:user] = users(:james).id
    post :publish, :lookup => users(:anonymous1).id
    assert_redirected_to :controller => 'taxonomy', :action => 'build'
  end

  def test_publishing_not_post
    @request.session[:user] = users(:admin).id
    get :publish, :lookup => users(:anonymous1).id
    assert_response 0
  end


#  def test_assigning
#  
#    c = PersonalCategory.new({:name => "aha", :status => "assigned", :level => 0})  
#    assert c.save!
#  
#    @request.session[:user] = users(:admin).id
#    post :assign, :lookup => users(:anonymous1).id
#    assert_redirected_to :controller => 'taxonomy', :action => 'build'
#    
#    assert Category.find_all_by_status("deleted").length > 0
#  end
#
#  def test_not_admin_assigning
#    @request.session[:user] = users(:james).id
#    post :publish, :lookup => users(:anonymous1).id
#    assert_redirected_to :controller => 'taxonomy', :action => 'build'
#  end
#
#  def test_assigning_not_post
#    @request.session[:user] = users(:admin).id
#    get :publish, :lookup => users(:anonymous1).id
#    assert_response 0
#  end


  
end
