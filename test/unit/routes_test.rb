require File.dirname(__FILE__) + '/../test_helper'

class RoutesTest < Test::Unit::TestCase

  def test_remove_category
    opts = {:controller => 'taxonomy', :action => 'remove_category', :id => '176'}
    assert_recognizes opts, '/taxonomy/remove_category/176'  
    assert_routing '/taxonomy/remove_category/176', opts
  end
 
  def test_list_users
    opts = {:controller => 'taxonomy', :action => 'list', :lookup => '123'}
    assert_recognizes opts, '/taxonomy/list/123'  
    assert_routing '/taxonomy/list/123', opts
  end 
  
  def test_build_users
    opts = {:controller => 'taxonomy', :action => 'build', :lookup => '123'}
    assert_recognizes opts, '/taxonomy/build/123'  
    assert_routing '/taxonomy/build/123', opts
  end   

  def test_new
    opts = {:controller => 'welcome', :action => 'consent'}
    assert_recognizes opts, ''  
    assert_routing '', opts
  end  
  
  def test_taxonomy
    opts = {:controller => 'taxonomy', :action => 'build'}
    assert_recognizes opts, '/taxonomy'  
    assert_routing '/taxonomy', opts
  end  

  def test_help
    opts = {:controller => 'welcome', :action => 'help'}
    assert_recognizes opts, '/welcome/help'  
    assert_routing '/welcome/help', opts
  end  

  def test_view
    opts = {:controller => 'taxonomy', :action => 'latest'}
    assert_recognizes opts, '/latest'  
    assert_routing '/latest', opts
  end  
  
 
end