require File.dirname(__FILE__) + '/../test_helper'
require 'welcome_controller'

# Re-raise errors caught by the controller.
class WelcomeController; def rescue_action(e) raise e end; end

class WelcomeControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @old_value_application_mode = $application_mode
    $application_mode = "create_new"
    
    @controller = WelcomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    @emails = ActionMailer::Base.deliveries
    @emails.clear
  end

  def teardown
    $application_mode = @old_value_application_mode
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'consent'
  end

  def test_intro
    get :intro
    assert !assigns(:user).nil?
  end
  
  def test_post_signin_no_email
    num_users = User.count
  
    post :signin, :user => {:email => ''}
    assert_response :redirect
    assert assigns(:user).anonymous?
    assert !assigns(:user).new_record?
    assert_equal num_users + 1, User.count
    assert_equal assigns(:user).id, @request.session[:user]
    assert_redirected_to :controller => 'taxonomy', :action => 'build'
  end

  def test_post_signin_no_email_means_no_email
    test_post_signin_no_email
    
    assert_equal 0, @emails.length
  end

  def test_post_signin_new_email
    num_users = User.count
  
    post :signin, :user => {:email => 'anew@email.ca'}
    assert_response :redirect
    assert_redirected_to :controller => 'taxonomy', :action => 'build'
    assert_equal num_users + 1, User.count
    
    assert !assigns(:user).anonymous?
    assert !assigns(:user).new_record?
    assert_equal 'anew@email.ca', assigns(:user).email
    assert_equal assigns(:user).id, @request.session[:user]
    
  end

  def test_post_signin_new_email_sends_email
    test_post_signin_new_email

    assert_equal 1, @emails.length
    
    email = @emails.first
    assert_equal 'Software Application Taxonomy - Your Secret Password', email.subject
  end

  def test_post_signin_existing_email
    num_users = User.count
  
    post :signin, :user => {:email => 'james@email.ca'}
    assert_equal num_users, User.count
    assert_response :redirect
    assert_equal 'james@email.ca', @request.session[:unverified_email]
    assert_redirected_to :action => 'verify'
  end

  def test_post_verify_update_status_if_withdrawn
    james = users(:james) 
    james.status = 'withdrawn'
    assert james.save
 
    @request.session[:unverified_email] = users(:james).email
    post :verify, :user => {:password => 'pqrs'}
    
    newjames = User.find_by_id(james.id)
    assert_equal 'inprogress', newjames.status
  end

  def test_post_verify_leave_status_alone_if_admin
    @request.session[:unverified_email] = users(:admin).email
    post :verify, :user => {:password => 'ab12'}
    
    newjames = User.find_by_id(users(:admin).id)
    assert_equal 'admin', newjames.status
  end

  
  def test_get_signin_redirects
    num_users = User.count
  
    get :signin, :user => {:email => ''}
    assert_response :redirect
    assert_redirected_to :action => 'intro'
    assert_equal num_users, User.count
  end
    
  def test_check_authentication_ignore_on_intro
    get :intro
    assert_response :success
  end

  def test_check_authentication_ignore_on_consent
    get :consent
    assert_response :success
  end
  
  def test_get_verify
    @request.session[:unverified_email] = users(:james).email
    get :verify
    assert assigns(:user)
  end
  
  def test_get_verify_no_unverified
    get :verify
    assert_response :redirect
    assert_redirected_to :action => 'intro'  
  end
  
  def test_post_verify_okay
    @request.session[:unverified_email] = users(:james).email
    post :verify, :user => {:password => 'pqrs'}

    assert_response :redirect
    assert_equal assigns(:user).id, @request.session[:user]
    assert_redirected_to :controller => 'taxonomy', :action => 'build'
  end

  def test_post_verify_invalid_password
    @request.session[:unverified_email] = 'james@email.ca'
    post :verify, :user => {:password => 'blah'}
    assert_response :success
    assert_equal 'Invalid password, please try again', flash[:notice]
    assert 'james@email.ca', assigns(:user).email
  end

  
  def test_post_verify_no_unverified_user
    post :verify
    assert_response :redirect
    assert assigns(:user)
    assert_redirected_to :action => 'intro'
  end
  
  def test_signin_redirects_as_required_ignore_intended_action
    @request.session[:intended_action] = 'consent'
    @request.session[:intended_controller] = 'welcome'
    post :signin, :user => { :email => 'anew@email.ca' }
    assert_response :redirect
    assert_redirected_to :controller => 'taxonomy', :action => 'build'
  end
  
  def test_get_withdraw
    @request.session[:user] = users(:anonymous1).id
    get :withdraw
    assert_response :redirect
    assert_redirected_to :action => 'intro'
  end
  
  def test_post_withdraw_not_logged_in
    post :withdraw
    assert_response :redirect
    assert_redirected_to :action => 'intro'
  end

  def test_post_withdraw
    @request.session[:user] = users(:anonymous1).id
    post :withdraw
    assert_response :success
    
    u = User.find_by_id(users(:anonymous1).id)
    assert_equal 'withdrawn', u.status
  end

  def test_get_complete
    @request.session[:user] = users(:anonymous1).id
    get :complete
    assert_response :redirect
    assert_redirected_to :action => 'intro'
  end
  
  def test_post_complete_not_logged_in
    post :complete
    assert_response :redirect
    assert_redirected_to :action => 'intro'
  end

  def test_post_complete
    @request.session[:user] = users(:anonymous1).id
    post :complete
    assert_response :success
    
    u = User.find_by_id(users(:anonymous1).id)
    assert_equal 'complete', u.status
  end

  def test_get_inprogress
    @request.session[:user] = users(:anonymous1).id
    get :inprogress
    assert_response :redirect
    assert_redirected_to :action => 'intro'
  end
  
  def test_post_inprogress_not_logged_in
    post :inprogress
    assert_response :redirect
    assert_redirected_to :action => 'intro'
  end

  def test_post_inprogress_build
    $application_mode = "create_new"
  
    @request.session[:user] = users(:anonymous1).id
    post :inprogress
    assert_response :redirect
    assert_redirected_to :controller => 'taxonomy', :action => 'build'
    
    u = User.find_by_id(users(:anonymous1).id)
    assert_equal 'inprogress', u.status
  end
  
  def test_edit_action
    $application_mode = "modify_latest"
    assert_equal "evaluate", @controller.edit_action
    
    $application_mode = "create_new"
    assert_equal "build", @controller.edit_action
    
    $application_mode = "create_empty"
    assert_equal "build", @controller.edit_action
    
  end
  
  
end
