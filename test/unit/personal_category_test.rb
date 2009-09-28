require File.dirname(__FILE__) + '/../test_helper'

class PersonalCategoryTest < Test::Unit::TestCase
  fixtures :categories
  fixtures :personal_categories
  fixtures :users
  
  def setup
    @mydevtools = personal_categories(:mydevtools)
    @myplugin = personal_categories(:myplugin)
    @mycodesnippets = personal_categories(:mycodesnippets)
  end

  def test_fixtures
    assert personal_categories(:mydevtools).valid?
    assert personal_categories(:myplugin).valid?
    assert personal_categories(:mycodesnippets).valid?
  end
  
  def test_requiredFields
    pc = PersonalCategory.new
    assert !pc.valid?
    assert pc.errors.on(:name)
    assert pc.errors.on(:level)
    assert pc.errors.on(:user_id)
    
    pc.name = "myname";
    assert !pc.valid?
    assert !pc.errors.on(:name)
    assert pc.errors.on(:level)
    assert pc.errors.on(:user_id)
    
    pc.level = 0;
    assert !pc.valid?
    assert !pc.errors.on(:name)
    assert !pc.errors.on(:level)
    assert pc.errors.on(:user_id)
    
    pc.user_id = users(:james).id
    assert pc.valid?
    
  end  
  
  def test_levelIsNumber
    c = PersonalCategory.new({:name => "aha", :user_id => users(:james).id})
    
    c.level = nil
    assert !c.valid?
    assert c.errors.on(:level)
    assert !c.errors.on(:name)
  
    c.level = ""
    assert !c.valid?
    assert c.errors.on(:level)
    assert !c.errors.on(:name)
    
    c.level = "a"
    assert !c.valid?
    assert c.errors.on(:level)
    assert !c.errors.on(:name)
    
    c.level = 0
    assert c.valid?
    assert !c.errors.on(:level)
    assert !c.errors.on(:name)
  
  end
  
  def test_levelInRange  
    c = PersonalCategory.new({:name => "aha", :user_id => users(:james).id})
    
    c.level = 4
    assert !c.valid?
    assert c.errors.on(:level)
    assert !c.errors.on(:name)
    
    c.level = -1
    assert !c.valid?
    assert c.errors.on(:level)
    assert !c.errors.on(:name)
    
    c.level = 0
    assert c.valid?
    
    c.level = 1
    assert c.valid?

    c.level = 2
    assert c.valid?

    c.level = 3
    assert c.valid?
  end  
  
  def test_statusInRange
    c = PersonalCategory.new({:name => "aha", :user_id => users(:james).id, :level => 0, :status => ''})
    
    assert !c.valid?
    assert c.errors.on(:status)
    
    c.status = 'blah'
    assert !c.valid?
    assert c.errors.on(:status)
    
    c.status = 'assigned'
    assert c.valid?
    
    c.status = 'unassigned'
    assert c.valid?

    c.status = 'deleted'
    assert c.valid?
  
  end

  
  def test_cannotAddDuplicateNameLevelAndUser
    c = PersonalCategory.new(:name => "Development tools", :level => 0, :user_id => 1)
    assert !c.valid?
    assert c.errors.on_base
    
  end
  
  def test_canAddDuplicateNamesOnDifferentLevels
    c = PersonalCategory.new(:name => "Development tools", :level => 1, :user_id => 1)
    assert c.valid?  
  end
  
  def test_canAddDuplicateNamesOnDifferentUsers
    c = PersonalCategory.new(:name => "Development tools", :level => 0, :user_id => 2)
    assert c.valid?  
  end
  
  def test_foreign_key_on_category
    c = PersonalCategory.new(:name => "name", :level => 0, :user_id => 1, :category_id => -1)
    assert !c.valid?
    assert c.errors.on(:category_id)
    
    c.category_id = categories(:devtools).id
    assert c.valid?
    assert !c.errors.on(:category_id)
  end

  def test_foreign_key_on_user
    c = PersonalCategory.new(:name => "name", :level => 0, :user_id => -1)
    assert !c.valid?
    assert c.errors.on(:user_id)
    
    c.user_id = users(:james).id
    assert c.valid?
    assert !c.errors.on(:user_id)
  end
  
  def test_belongs_to_user
    c = PersonalCategory.new
    c.user = users(:james)
    assert users(:james).id, c.user_id
  end
  
  def test_belongs_to_category
    c = PersonalCategory.new
    c.category = categories(:devtools)
    assert categories(:devtools).id, c.category_id
  end
  
  def test_empty_has_first_level_by_default
    c = PersonalCategory.empty 'myname', 2
    assert_equal 'myname', c.name
    assert_equal 2, c.level
    assert_equal nil, c.id
    assert_equal nil, c.parent_id
  end
  
  def test_remove_okay
    c = personal_categories(:mydevtools)
    
    assert c.remove!
    assert 'deleted', c.status
    
    same_c = PersonalCategory.find_by_id(c.id)
    assert_equal 'deleted', same_c.status
  end

  def test_remove_cascade
    assert @mydevtools.add_child!(@myplugin)
    
    assert @mydevtools.remove!
    assert 'deleted', @mydevtools.status
    assert 'deleted', @myplugin.status
    assert_equal nil, @mydevtools.parent_id
        
    same1 = PersonalCategory.find_by_id(@mydevtools.id)
    same2 = PersonalCategory.find_by_id(@myplugin.id)
    assert_equal 'deleted', same1.status
    assert_equal 'deleted', same2.status
    assert_equal nil, same1.parent_id
    assert_equal nil, same2.parent_id
  end
  
  def test_children_unassigned
    @mydevtools.status = 'unassigned'
    @myplugin.parent_id = @mydevtools.id
    assert @mydevtools.save
    assert @myplugin.save

    assert_equal 0, @mydevtools.children.length
  end
  
  def test_children_deleted
    @mydevtools.status = 'deleted'
    @myplugin.parent_id = @mydevtools.id
    assert @mydevtools.save
    assert @myplugin.save
    
    assert_equal 0, @mydevtools.children.length
  end
  
  def test_children_assigned
    @mydevtools.status = 'assigned'
    @myplugin.parent_id = @mydevtools.id
    @myplugin.status = 'assigned'
    assert @mydevtools.save
    assert @myplugin.save
    
    assert_equal 1, @mydevtools.children.length
    assert_equal @myplugin.id, @mydevtools.children[0].id
  end

  def test_children_only_assigned
    @mydevtools.status = 'assigned'
    @myplugin.parent_id = @mydevtools.id
    @myplugin.status = 'unassigned'
    assert @mydevtools.save
    assert @myplugin.save
    
    assert_equal 0, @mydevtools.children.length
  end

  def test_children_different_users
    @mydevtools.status = 'assigned'
    @mydevtools.user = users(:anonymous1)
    @myplugin.parent_id = @mydevtools.id
    @myplugin.user = users(:james)
    assert @mydevtools.save
    assert @myplugin.save
    
    assert_equal 0, @mydevtools.children.length
  end
  
  def test_add_child
    @mydevtools.level = 0;
    @myplugin.level = 2;
  
    assert @mydevtools.add_child!(@myplugin)
    assert_equal @mydevtools.id, @myplugin.parent_id
    assert_equal 1, @myplugin.level
    assert_equal 'assigned', @mydevtools.status
    assert_equal 'assigned', @myplugin.status
    
    saved1 = PersonalCategory.find_by_id @mydevtools.id
    saved2 = PersonalCategory.find_by_id @myplugin.id
    
    assert_equal 'assigned', saved1.status
    assert_equal 'assigned', saved2.status
  end

  def test_add_child_already_at_last_level
    @mydevtools.level = LAST_LEVEL;
    assert !@mydevtools.add_child!(@myplugin)
    assert @myplugin.parent_id != @mydevtools.id
    assert_equal 'unassigned', @mydevtools.status
    assert_equal 'unassigned', @myplugin.status
  end

  def test_add_child_has_children_at_last_level
    @mydevtools.level = 2 and @mydevtools.save!
    @myplugin.level = 2 and @myplugin.save!
    assert @myplugin.add_child!(@mycodesnippets)
  
    assert_equal 1, @myplugin.children.length;
    assert @mydevtools.add_child!(@myplugin)
    saved = PersonalCategory.find_by_id @mycodesnippets.id
    
    assert_equal @mydevtools.id, saved.parent_id
    assert_equal LAST_LEVEL, saved.level
  end
  
  def test_add_child_has_grandchildren_beyond_last_level
  
    grandchild = PersonalCategory.new(:name => "grand child", :level => 0, :user_id => 2)
    assert grandchild.save!

    @mydevtools.level = 1 and @mydevtools.save!
    @myplugin.level = 1 and @myplugin.save!
    assert @myplugin.add_child!(@mycodesnippets)
    assert @mycodesnippets.add_child!(grandchild)

    assert @mydevtools.add_child!(@myplugin)

    saved = PersonalCategory.find_by_id @myplugin.id
    assert_equal @mydevtools.id, saved.parent_id
    assert_equal 2, saved.level

    saved = PersonalCategory.find_by_id @mycodesnippets.id
    assert_equal @myplugin.id, saved.parent_id
    assert_equal 3, saved.level
    
    saved = PersonalCategory.find_by_id grandchild.id
    assert_equal @myplugin.id, saved.parent_id
    assert_equal 3, saved.level
    assert_equal 1, saved.user_id
  
  end

  
  def test_add_child_new_record_saves_as_root
    @mydevtools.level = 2
    assert PersonalCategory.new.add_child!(@mydevtools)
    assert_equal FIRST_LEVEL, @mydevtools.level
    assert_equal nil, @mydevtools.parent_id
  end
  
  def test_add_root_new_record_saves_as_root
    @mydevtools.level = 2
    assert PersonalCategory.add_root!(@mydevtools)
    assert_equal FIRST_LEVEL, @mydevtools.level
    assert_equal nil, @mydevtools.parent_id
  end
  
  def test_add_root_sets_parent_id_nil
    @mydevtools.parent_id = 10
    assert PersonalCategory.add_root!(@mydevtools)
    assert_equal nil, @mydevtools.parent_id
  end
  
  def test_store_entire_structure
    
    assert @mydevtools.add_child!(@myplugin)
    assert @myplugin.add_child!(@mycodesnippets)
    
    cached_version = PersonalCategory.find_by_id(@mydevtools.id)
    uncached_version = cached_version.dup
    
    cached_version = cached_version.store_entire_structure!
    assert @mydevtools.remove!

    assert_equal 1, cached_version.children.length
    assert_equal 1, cached_version.children[0].children.length
    assert_equal 'assigned', cached_version.status
    
    assert_equal 0, uncached_version.children.length
  
  end
  
  def test_prefix
    c = PersonalCategory.new
    
    c.level = 0
    assert_equal 'C', c.prefix
    
    c.level = 1
    assert_equal 'SC', c.prefix
    
    c.level = 2
    assert_equal 'SSC', c.prefix
    
    c.level = 3
    assert_equal 'SSSC', c.prefix
    
  end
  
  def test_equal_same_id
    c10 = PersonalCategory.new
    also_c10 = PersonalCategory.new
    c10.id = 10
    also_c10.id = 10
    assert_equal c10.id, also_c10.id
    assert_equal c10, also_c10  
  end

  def test_not_equal_not_same_id
    c10 = PersonalCategory.new()
    not_c10 = PersonalCategory.new()
    c10.id = 10
    not_c10.id = 11
    assert_not_equal c10, not_c10  
  end

  def test_not_equal_not_same_type
    c10 = PersonalCategory.new()
    assert_not_equal c10, "abc"  
  end
  
  def test_hash_based_on_save_id
    c10 = PersonalCategory.new({:id => 10})
    also_c10 = PersonalCategory.new({:id => 10})
    not_c10 = PersonalCategory.new({:id => 11})
    
    myhash = Hash.new
    myhash[c10] = "abc"
    
    assert_equal "abc", myhash[c10]
    assert_equal "abc", myhash[also_c10]
    assert_equal false, myhash[also_c10] != "abc"
    
  end
  
      
end
