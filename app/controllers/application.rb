# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base

  protected 
    def check_authentication
      @user = User.find_by_id(session[:user]) if session[:user]
      if @user.nil?
        session[:user] = nil
        session[:intended_action] = action_name
        session[:intended_controller] = controller_name
        redirect_to :controller => 'welcome', :action => 'intro'
      end
    end
end