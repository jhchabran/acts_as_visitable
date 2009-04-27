require File.dirname(__FILE__) + '/spec_helper'

describe ActsAsVisitable do
  describe "Basic operations" do 
    before :each do
      @user = User.create(valid_user_attributes)
      @foo = Foo.create(valid_foo_attributes)
    end
    it "should include ActsAsVisitable in Foo" do
      Foo.should include(ActsAsVisitable)
    end

    it "should declare a has_many relationship between Foo and Visit" do
      Foo.reflections.should include(:visits)
      Foo.reflections[:visits].macro.should be_eql(:has_many)
    end

    it "should let a foo be visited by a user" do
      lambda { @foo.visited_by(@user) }.should change(@user.visited_objects, :count).by(1)
      @foo.visited_by?(@user).should be_true
      @foo.visited_by?(User.create(valid_user_attributes)).should be_false
      @user.visited?(@foo).should be_true
    end

    it "should let a user visit a foo " do
      lambda { @user.visit(@foo) }.should change(@user.visited_objects, :count).by(1)
      @user.visited?(@foo).should be_true
      @user.visited?(Foo.create(valid_foo_attributes)).should be_false
      @foo.visited_by?(@user).should be_true
    end

    it "should let a user visit many foos" do
      lambda { @user.visit(@foo) }.should change(@user.visited_objects, :count).by(1)
      lambda { @user.visit(Foo.create(valid_foo_attributes)) }.should change(@user.visited_objects, :count).by(1)
    end

    it "should let a foo be visited by many users" do
      lambda { @foo.visited_by(@user) }.should change(@foo.visits, :count).by(1)
      lambda { @foo.visited_by(User.create(valid_user_attributes)) }.should change(@foo.visits, :count).by(1)
    end

    it "should let a user visit a Foo and a Lambda" do
      lambda do
        @user.visit(@foo)
        @user.visit(Bar.create(:size => 3))
      end.should change(Visit, :count).by(2)
    end

    it "should not create a Visit where one already exists (user visited a foo)" do
      lambda { @user.visit(@foo); @user.visit(@foo) }.should change(@user.visited_objects, :count).by(1)
    end

    it "should not create a Visit where one already exists (foo visited by a user)" do
      lambda { @foo.visited_by(@user); @foo.visited_by(@user) }.should change(@user.visited_objects, :count).by(1)
    end

    it "should have a timestamp" do
      @user.visit(@foo).visited_at.should_not be_nil
    end

    it "should update timestamp when visited again" do
      # waiting for one second in specs is tiring 
      # @user.saw(@foo).tap{ sleep 1 }.seen_at.should_not be_eql(@user.saw(@foo).seen_at)
    end

    it "should not let a user visit something which is not a foo" do
      lambda { @user.visit(SomethingElse.new) }.should raise_error
    end
  end

  describe "Seen and Viewer selections" do
    before :all do 
      @user = User.create(valid_user_attributes)
      @another_user = User.create(valid_user_attributes)

      @foo = Foo.create(valid_foo_attributes)
      @another_foo = Foo.create(valid_foo_attributes)

      @bar = Bar.create(valid_bar_attributes)
      @another_bar = Bar.create(valid_bar_attributes)

      @user.visit(@foo)
      @user.visit(@another_foo)

      @user.visit(@bar)
      @user.visit(@another_bar)

      @another_user.visit(@bar)
      @another_user.visit(@foo)
    end
    
    it "User should have named scopes to load visited foos and bars" do
      User.visited_foos.should_not be_empty
      User.visited_bars.should_not be_empty
    end

    it "Foo and Bar should have named scopes to get users that visited them" do
      Foo.visitors.should_not be_empty
      Bar.visitors.should_not be_empty
    end

    it "should find all user that have visited a foo" do
      User.which_visited(@foo).should have(2).items
      User.which_visited(@bar).should have(2).items
    end

    it "should find all foo and bars that have been visited by a user" do
      @user.visited?(@foo).should be_true
      @another_user.visited?(@foo).should be_true
      
      Foo.visited_by(@user).should have(2).items
      Bar.visited_by(@user).should have(2).items
    end

    it "should find all content visited by a user" do
      @user.visited.should have(4).items
    end

    it "should find all users which visited a foo" do
      @foo.visitors.should have(2).items
    end
  end
  
  describe "Self references" do
    before :each do 
      @user = User.create valid_user_attributes
      @another_user = User.create valid_user_attributes
    end
    
    it "should let a user visit another user" do
      @user.visit(@another_user)
      @user.visited?(@another_user).should be_true
      @another_user.should be_visited_by(@user)
    end
    
    it "should not let a user visit himself" do
      @user.visit(@user).should be_nil
    end
  end
  
  describe 'Serialization' do
    before :all do 
      @user = User.create valid_user_attributes
      @foo = Foo.create valid_foo_attributes
      @another_foo = Foo.create valid_foo_attributes
    end
    
    it "should have a visited flag when serialized with 'seen_by' option" do
      @user.visit(@foo)
      @foo.to_json(:visited_by => @user).should include('visited')
      @foo.to_json.should_not include('visited')
    end
    
    it "should have many visited flags when serializing a collection" do
      @user.visit(@foo)
      @user.visit(@another_foo)
      [@foo, @another_foo].to_json(:visited_by => @user).should include('visited')
    end
  end
end