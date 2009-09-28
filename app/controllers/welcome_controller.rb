class WelcomeController < ApplicationController
  layout 'taxonomy'
  
  before_filter :check_authentication, :only => [:withdraw, :complete, :inprogress]
  verify :method => "post", :only => [ :signin, :withdraw, :complete, :inprogress ], :redirect_to => { :action => 'intro' }

  def index
    render :action => 'consent'
  end

  def intro
    @user = User.new
  end
  
  def signin
    existing_user = User.find_by_email(params[:user][:email])
    if existing_user.nil?
      @user = User.new(params[:user])
      if @user.save
        email = PasswordMailer.create_password(@user) 
        PasswordMailer.deliver(email) unless @user.anonymous?
        login_user
      end
    else
      @user = User.new
      session[:unverified_email] = existing_user.email
      redirect_to :action => 'verify'
    end    
  end
  
  def verify
    email = session[:unverified_email]
    if email.nil?
      intro
      redirect_to :action => 'intro'
      return
    end
    if request.post?
      @user = User.authenticate(email,params[:user][:password])
      unless @user.nil?
        login_user
        return
      else
        flash[:notice] = 'Invalid password, please try again'
      end
    end
    @user = User.new({ :email => email })
  end
  
  def withdraw
    @user.status = 'withdrawn'
    @user.save
  end
  
  def complete
    @user.status = 'complete'
    @user.save
  end
  
  def inprogress
    @user.status = 'inprogress'
    @user.save
    redirect_to :controller => 'taxonomy', :action => edit_action
  end
  
  def edit_action
    return "list" if !@user.nil? and @user.admin?
    $application_mode == "modify_latest" ? "evaluate" : "build"
  end  

  protected 
    def login_user
      @user.status = 'inprogress' and @user.save if @user.status == 'withdrawn'
      session[:user] = @user.id
      redirect_to :controller => 'taxonomy', :action => edit_action
    end
    

    
end