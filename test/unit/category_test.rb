require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories

  def setup
    @old_value_application_mode = $application_mode
  
    @devtools = categories(:devtools)
    @plugin = categories(:plugin)
    @codesnippets = categories(:codesnippets)        
  end
  
  def teardown
    $application_mode = @old_value_application_mode
  end

  def test_fixtures
    assert categories(:devtools).valid?
    assert categories(:plugin).valid?
    assert categories(:codesnippets).valid?
    
    assert_equal 'unassigned', categories(:devtools).status
    assert_equal 'unassigned', categories(:plugin).status
    assert_equal 'unassigned', categories(:codesnippets).status    
  end
  
  def test_requiredFields
    c = Category.new
    assert !c.valid?
    assert c.errors.on(:name)
    assert c.errors.on(:level)
    
    c.name = "myname";
    assert !c.valid?
    assert !c.errors.on(:name)
    assert c.errors.on(:level)
    
    c.level = 0;
    assert c.valid?

  end
  
  def test_levelIsNumber
    c = Category.new({:name => "aha"})
    
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
    c = Category.new({:name => "aha"})
    
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
    c = Category.new({:name => "aha",:level => 0,:status => ''})
    
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
  
  def test_class_findOrCreateByNew
    category_count = Category.count
    assert_nil Category.find_by_name("myname")
    
    c = Category.find_or_create_by_name_and_level("myname",1)
    assert_equal "myname", c.name
    assert_equal 1, c.level
    assert_equal category_count+1, Category.count
    assert !c.new_record?
    assert Category.exists?(c.id)
    assert_not_nil Category.find_by_name("myname")
  end

  def test_class_findOrCreateByExisting
    category_count = Category.count
    assert_nil Category.find_by_name("myname")
    
    c = Category.find_or_create_by_name_and_level("Development tools",0)
    assert_equal "Development tools", c.name
    assert_equal 0, c.level
    assert_equal category_count, Category.count
    assert !c.new_record?
    assert Category.exists?(c.id)
    assert_equal categories(:devtools).id, c.id
  end

  
  def test_class_createWithHash
    category_count = Category.count
    assert_nil Category.find_by_name("myname")
    
    params = { :name => "myname", :level => 1 }
    c = Category.new(params)
    assert_equal "myname", c.name
    assert_equal 1, c.level
    assert c.save
    assert_equal category_count+1, Category.count
    assert !c.new_record?
    assert Category.exists?(c.id)
    assert_not_nil Category.find_by_name("myname")
  
  
  end
  
  def test_cannotAddDuplicateNamesAndLevels
    
    c = Category.new(:name => "Development tools", :level => 0)
    assert !c.valid?
    assert c.errors.on_base
    
  end
  
  def test_canAddDuplicateNamesOnDifferentLevels
    c = Category.new(:name => "Development tools", :level => 1)
    assert c.valid?  
  end

  def test_latest_empty
    organized = Category.latest
    assert_equal 0, organized.length
  end

  def test_latest_ignore_unassigned_and_deleted
    
    c1 = Category.new({:name => "a", :level => 0, :status => 'unassigned' })
    c2 = Category.new({:name => "b", :level => 0, :status => 'assigned' })
    c3 = Category.new({:name => "c", :level => 0, :status => 'deleted' })
    assert c1.save
    assert c2.save
    assert c3.save
    
    c2a = Category.new({:name => '2a', :level => 1, :parent_id => c2.id, :status => 'unassigned'})
    assert c2a.save
    
    organized = Category.latest
    assert_equal 1, organized.length
    assert_equal "b", organized[0].name
    assert_equal 0, c2.children.length
        
  end
  
  def test_latest_categories_level0
    
    c1 = Category.new({:name => "a", :level => 0, :status => 'assigned' })
    c2 = Category.new({:name => "b", :level => 0, :status => 'assigned' })
    assert c1.save
    assert c2.save
    
    organized = Category.latest
    assert_equal 2, organized.length
    
    assert_equal "a", organized[0].name
    assert_equal "b", organized[1].name
        
  end  
  
  def test_latest_categories_hasChildren
    c1 = Category.new({:name => "aFirst", :level => 0, :status => 'assigned' })
    c2 = Category.new({:name => "bLast", :level => 0, :status => 'assigned' })
    assert c1.save
    assert c2.save

    c1a = Category.new({:name => '1a', :level => 1, :parent_id => c1.id, :status => 'assigned' })
    c1b = Category.new({:name => '1b', :level => 1, :parent_id => c1.id, :status => 'assigned' })
    c2a = Category.new({:name => '2a', :level => 1, :parent_id => c2.id, :status => 'assigned' })

    assert c1a.save
    assert c1b.save
    assert c2a.save

    organized = Category.latest
    assert_equal 2, organized.length
    
    assert_equal "aFirst", organized[0].name
    assert_equal "bLast", organized[1].name

    assert_equal 2, c1.children.length
    assert_equal 1, c2.children.length

    assert "1a", c1.children[0].name
    assert "1b", c1.children[1].name
    assert "2a", c2.children[0].name
  end  
  
  def test_calculate_prefix_for
    c = Category.new
    
    c.level = 0
    assert_equal 'C', Category.calculate_prefix_for(c)
    
    c.level = 1
    assert_equal 'SC', Category.calculate_prefix_for(c)
    
    c.level = 2
    assert_equal 'SSC', Category.calculate_prefix_for(c)
    
    c.level = 3
    assert_equal 'SSSC', Category.calculate_prefix_for(c)
    
  end   
  
  def test_prefix
    c = Category.new
    
    c.level = 0
    assert_equal 'C', c.prefix
    
    c.level = 1
    assert_equal 'SC', c.prefix
    
    c.level = 2
    assert_equal 'SSC', c.prefix
    
    c.level = 3
    assert_equal 'SSSC', c.prefix
    
  end  
  



  def test_children_unassigned
    @devtools.status = 'unassigned'
    @plugin.parent_id = @devtools.id
    assert @devtools.save
    assert @plugin.save

    assert_equal 0, @devtools.children.length
  end
  
  def test_children_deleted
    @devtools.status = 'deleted'
    @plugin.parent_id = @devtools.id
    assert @devtools.save
    assert @plugin.save
    
    assert_equal 0, @devtools.children.length
  end
  
  def test_children_assigned
    @devtools.status = 'assigned'
    @plugin.parent_id = @devtools.id
    @plugin.status = 'assigned'
    assert @devtools.save
    assert @plugin.save
    
    assert_equal 1, @devtools.children.length
    assert_equal @plugin.id, @devtools.children[0].id
  end

  def test_children_only_assigned
    @devtools.status = 'assigned'
    @plugin.parent_id = @devtools.id
    @plugin.status = 'unassigned'
    assert @devtools.save
    assert @plugin.save
    
    assert_equal 0, @devtools.children.length
  end

  def test_publish_delete_existing
    u = User.new
    assert u.save
    Category.publish(u)
    Category.find(:all).each do |category|
      assert_equal "deleted", category.status
    end
  end
  
  def test_publish_add_new
    u = User.new
    assert u.save
    
    c1 = PersonalCategory.new({:name => "a", :level => 0, :user_id => u.id, :status => 'assigned' })
    assert c1.save
    
    assert u.save
    Category.publish(u)
    Category.find(:all).each do |category|
      assert_equal "deleted", category.status if category.name != "a"
      assert_equal "assigned", category.status if category.name == "a"      
    end
  end  

  def test_publish_maintain_existing_same_level
    $application_mode = "create_new"
    u = User.new
    assert u.save
    
    c1 = PersonalCategory.find_by_name_and_user_id(@devtools.name,u.id)
    c1.status = "assigned"
    assert c1.save
    
    assert u.save
    Category.publish(u)
    Category.find(:all).each do |category|
      assert_equal "deleted", category.status if @devtools.id != category.id
      assert_equal "assigned", category.status if @devtools.id == category.id
    end
  end  

  def test_publish_maintain_existing_different_level
    $application_mode = "create_new"
    u = User.new
    assert u.save
        
    
    c1 = PersonalCategory.find_by_name_and_user_id(@codesnippets.name,u.id)
    c1.level = 0
    c1.status = "assigned"
    assert c1.save
    
    assert u.save
    Category.publish(u)
    Category.find(:all).each do |category|
      assert_equal "deleted", category.status if @codesnippets.id != category.id
      
      if @codesnippets.id == category.id
        assert_equal "assigned", category.status
        assert_equal 0, category.level
      end
    end
  end  


  def test_publish_maintain_hierachy
    u = User.new
    assert u.save
        
    pc1 = PersonalCategory.new({:name => "top", :level => 0, :user_id => u.id, :status => 'assigned' })
    pc2 = PersonalCategory.new({:name => "middle", :level => 1, :user_id => u.id, :status => 'assigned' })
    pc3 = PersonalCategory.new({:name => "bottom", :level => 2, :user_id => u.id, :status => 'assigned' })

    assert pc1.save
    assert pc2.save    
    assert pc3.save

    pc1.add_child!(pc2)
    pc2.add_child!(pc3)

    Category.publish(u)
    
    organized = Category.latest
    c1 = organized[0]
    c2 = c1.children[0]
    c3 = c2.children[0]
    
    assert_equal pc1.name, c1.name
    assert pc2.name, c2.name
    assert pc3.name, c3.name
    
    assert_equal 3, Category.find_all_by_status("assigned").length
  end

  def test_assign_latest_to_maintain_hierachy
    $application_mode == "create_empty"

    u = User.new
    assert u.save
        
    pc1 = PersonalCategory.new({:name => "top", :level => 0, :user_id => u.id, :status => 'assigned' })
    pc2 = PersonalCategory.new({:name => "middle", :level => 1, :user_id => u.id, :status => 'assigned' })
    pc3 = PersonalCategory.new({:name => "bottom", :level => 2, :user_id => u.id, :status => 'assigned' })

    assert pc1.save
    assert pc2.save    
    assert pc3.save

    pc1.add_child!(pc2)
    pc2.add_child!(pc3)

    Category.publish(u)
    u = User.find_by_id(u.id)

    PersonalCategory.delete_all("user_id = #{u.id}")
    Category.assign_latest_to(u)
    
    organized = u.organized_categories
    pc1a = organized[0]
    pc2a = pc1a.children[0]
    pc3a = pc2a.children[0]
    
    assert_equal pc1.name, pc1a.name
    assert pc2.name, pc2a.name
    assert pc3.name, pc3a.name  

    assert_equal nil, pc1a.parent_id
    assert pc1a.id, pc2a.parent_id
    assert pc2a.id, pc3a.parent_id  

    assert_equal 3, Category.find_all_by_status("assigned").length
  end


  
end

