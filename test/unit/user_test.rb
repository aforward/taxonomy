require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users
  fixtures :categories

  def setup
    @old_value_application_mode = $application_mode
  end
  
  def teardown
    $application_mode = @old_value_application_mode
  end

  def test_fixtures
    assert users(:anonymous1).valid?
    assert users(:james).valid?
  end
  
  def test_admin?
    u = User.new
    assert !u.admin?
    
    u.status = 'admin'
    assert u.admin?
    
    u.status = 'blah'
    assert !u.admin?
    
  end
  
  def test_status
    u = users(:james)
    u.status = ''
    assert !u.valid?
    assert u.errors.on(:status)
    
    u.status = 'x'
    assert !u.valid?
    assert u.errors.on(:status)

    u.status = 'inprogress'
    assert u.valid?

    u.status = 'complete'
    assert u.valid?
    
    u.status = 'withdrawn'
    assert u.valid?
        
  end
  
  def test_anonymous_user
    current_count = User.count

    u = User.new
    u.before_save
    assert_equal 'anonymous', u.email
  end
  
  def test_anonymous?
    u = User.new
    assert u.anonymous?
    
    u.email = 'anonymous'
    assert u.anonymous?
    
    u.email = 'notanonymous@email.ca'
    assert !u.anonymous?
    
    u.email = ''
    assert u.anonymous?
    
    assert users(:anonymous1).anonymous?
  end
  
  def test_save_creates_random_password
    u = User.new
    u.email = 'aha'
    assert u.save
    assert_equal 4, u.password.length
  end
  
  def test_save_without_email_creates_anonymous
    u = User.new
    assert u.save
    assert u.anonymous?
    assert_equal 4, u.password.length
  end
  
  def test_update_does_not_create_new_password
    u = User.new
    assert u.save
    oldpassword = u.password
    assert u.save
    assert_equal oldpassword, u.password
  end
  
  def test_new_password_length
   password = User.new_password
   assert_equal 4, password.length
   
   password = User.new_password 8
   assert_equal 8, password.length

  end
  
  def test_new_password_actually_random
    password1 = User.new_password
    password2 = User.new_password
    
    assert password1 != password2
  end
  
  def test_authenticate_wrong_email
    assert User.authenticate('unknown','1234').nil?
  end

  def test_authentication_wrong_password
    assert User.authenticate('james@email.ca','not pqrs').nil?
  end
  
  def test_authentication_okay
    assert users(:james).id, User.authenticate('james@email.ca','pqrs').id
  end

  def test_create_empty
    $application_mode = "create_empty"
    u = User.new
    assert u.save
    assert_equal 0, PersonalCategory.find_all_by_user_id(u.id).length
  end  
  
  
  def test_save_existing_user_does_not_add_categories
    $application_mode = "create_new"
    u = User.new
    assert u.save
    assert PersonalCategory.find_all_by_user_id(u.id).length > 0
    PersonalCategory.delete_all "user_id = #{u.id}"
    assert u.save
    assert_equal 0, PersonalCategory.find_all_by_user_id(u.id).length
  end  

  def test_add_new_user_copy_entire_structure
    $application_mode = "modify_latest"
    devtools = categories(:devtools)
    devtools.status = "assigned"
    devtools.save
    u = User.new
    assert u.save
    assert_equal devtools.name, PersonalCategory.find_by_user_id(u.id).name
    assert_equal 1, PersonalCategory.find_all_by_user_id(u.id).length
  end

  
  def test_add_new_user_creates_personal_categories

    $application_mode = "create_new"
    u = User.new
    assert u.save
    
    all_categories = Category.find(:all)
    all_personal_categories = PersonalCategory.find_all_by_user_id(u.id)
    assert_equal all_categories.length, all_personal_categories.length
    
    c = all_categories.first
    pc = all_personal_categories.first
    assert_equal u.id, pc.user_id
    assert_equal 'unassigned', pc.status
    assert_equal c.id, pc.category_id
    assert_equal c.name, pc.name
    assert_equal c.level, pc.level
  end

  def test_add_new_user_creates_4_to_7_categories
    $application_mode = "create_new"
    for i in 1..30
      level = rand(2) + 1
      Category.new({ :name => "Cat#{i}", :level => level }).save
    end

    u = User.new
    assert u.save
    all_personal_categories = PersonalCategory.find_all_by_user_id(u.id)
    assert all_personal_categories.length >= 4 and all_personal_categories.length <= 7

    u2 = User.new
    assert u2.save
    all_personal_categories2 = PersonalCategory.find_all_by_user_id(u2.id)
    assert all_personal_categories2.length >= 4 and all_personal_categories2.length <= 7

    u3 = User.new
    assert u3.save
    all_personal_categories3 = PersonalCategory.find_all_by_user_id(u3.id)
    assert all_personal_categories3.length >= 4 and all_personal_categories3.length <= 7

    u4 = User.new
    assert u4.save
    all_personal_categories4 = PersonalCategory.find_all_by_user_id(u4.id)
    assert all_personal_categories4.length >= 4 and all_personal_categories4.length <= 7

    u5 = User.new
    assert u5.save
    all_personal_categories5 = PersonalCategory.find_all_by_user_id(u5.id)
    assert all_personal_categories5.length >= 4 and all_personal_categories5.length <= 7

    u6 = User.new
    assert u6.save
    all_personal_categories6 = PersonalCategory.find_all_by_user_id(u6.id)
    assert all_personal_categories6.length >= 4 and all_personal_categories6.length <= 7

    u7 = User.new
    assert u7.save
    all_personal_categories7 = PersonalCategory.find_all_by_user_id(u7.id)
    assert all_personal_categories7.length >= 4 and all_personal_categories7.length <= 7

    assert all_personal_categories.length != all_personal_categories2.length or all_personal_categories.length != all_personal_categories3.length or all_personal_categories.length != all_personal_categories4.length or all_personal_categories.length != all_personal_categories5.length or all_personal_categories.length != all_personal_categories6.length or all_personal_categories.length != all_personal_categories7.length
    assert all_personal_categories[0].name != all_personal_categories2[0].name or all_personal_categories[0].name != all_personal_categories3[0].name or all_personal_categories[0].name != all_personal_categories4[0].name or all_personal_categories[0].name != all_personal_categories5[0].name or all_personal_categories[0].name != all_personal_categories6[0].name

  end


  def test_has_many_personal_categories
    u = users(:anonymous1)
    assert_equal 3, u.personal_categories.length
  end  
  
  def test_organized_categories_none
    u = users(:james)
    assert_equal 0, u.organized_categories.length
  end

  def test_organized_categories_ignore_unassigned_and_deleted
    u = users(:james)
    
    c1 = PersonalCategory.new({:name => "a", :level => 0, :user_id => u.id, :status => 'unassigned' })
    c2 = PersonalCategory.new({:name => "b", :level => 0, :user_id => u.id, :status => 'assigned' })
    c3 = PersonalCategory.new({:name => "c", :level => 0, :user_id => u.id, :status => 'deleted' })
    assert c1.save
    assert c2.save
    assert c3.save
    
    c2a = PersonalCategory.new({:name => '2a', :level => 1, :user_id => u.id, :parent_id => c2.id, :status => 'unassigned'})
    assert c2a.save
    
    organized = u.organized_categories
    assert_equal 1, organized.length
    assert_equal "b", organized[0].name
    assert_equal 0, c2.children.length
        
  end

  
  def test_organized_categories_level0
    u = users(:james)
    
    c1 = PersonalCategory.new({:name => "a", :level => 0, :user_id => u.id, :status => 'assigned' })
    c2 = PersonalCategory.new({:name => "b", :level => 0, :user_id => u.id, :status => 'assigned' })
    assert c1.save
    assert c2.save
    
    organized = u.organized_categories
    assert_equal 2, organized.length
    
    assert_equal "a", organized[0].name
    assert_equal "b", organized[1].name
        
  end

  def test_organized_categories_level1
    u = users(:james)
    
    c1 = PersonalCategory.new({:name => "aFirst", :level => 0, :user_id => u.id, :status => 'assigned' })
    c2 = PersonalCategory.new({:name => "bLast", :level => 0, :user_id => u.id, :status => 'assigned' })
    assert c1.save
    assert c2.save

    c1a = PersonalCategory.new({:name => '1a', :level => 1, :user_id => u.id, :parent_id => c1.id, :status => 'assigned' })
    c1b = PersonalCategory.new({:name => '1b', :level => 1, :user_id => u.id, :parent_id => c1.id, :status => 'assigned' })
    c2a = PersonalCategory.new({:name => '2a', :level => 1, :user_id => u.id, :parent_id => c2.id, :status => 'assigned' })

    assert c1a.save
    assert c1b.save
    assert c2a.save

    organized = u.organized_categories
    assert_equal 2, organized.length
    
    assert_equal "aFirst", organized[0].name
    assert_equal "bLast", organized[1].name

    assert_equal 2, c1.children.length
    assert_equal 1, c2.children.length

    assert "1a", c1.children[0].name
    assert "1b", c1.children[1].name
    assert "2a", c2.children[0].name
  end
end
