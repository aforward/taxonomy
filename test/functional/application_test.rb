require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class ApplicationController; def rescue_action(e) raise e end; end

class ApplicationControllerTest < Test::Unit::TestCase
  fixtures :users

  def setup
    @controller = ApplicationController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:james).id
  end

  def test_truth
    assert true
  end
end
