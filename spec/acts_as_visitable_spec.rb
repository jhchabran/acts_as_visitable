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

    it "should declare a has_many relationship between Foo and Sight" do
      Foo.reflections.should include(:sights)
      Foo.reflections[:sights].macro.should be_eql(:has_many)
    end

    it "should let a foo be seen by a user" do
      lambda { @foo.seen_by(@user) }.should change(@user.views, :count).by(1)
      @foo.seen_by?(@user).should be_true
      @foo.seen_by?(User.create(valid_user_attributes)).should be_false
      @user.saw?(@foo).should be_true
    end

    it "should let a user see a foo " do
      lambda { @user.saw(@foo) }.should change(@user.views, :count).by(1)
      @user.saw?(@foo).should be_true
      @user.saw?(Foo.create(valid_foo_attributes)).should be_false
      @foo.seen_by?(@user).should be_true
    end

    it "should let a user see many foos" do
      lambda { @user.saw(@foo) }.should change(@user.views, :count).by(1)
      lambda { @user.saw(Foo.create(valid_foo_attributes)) }.should change(@user.views, :count).by(1)
    end

    it "should let a foo be seen by many users" do
      lambda { @foo.seen_by(@user) }.should change(@foo.sights, :count).by(1)
      lambda { @foo.seen_by(User.create(valid_user_attributes)) }.should change(@foo.sights, :count).by(1)
    end

    it "should let a user see a Foo and a Lambda" do
      lambda do
        @user.saw(@foo)
        @user.saw(Bar.create(:size => 3))
      end.should change(Sight, :count).by(2)
    end

    it "should not create a sight where one already exists (user saw a foo)" do
      lambda { @user.saw(@foo); @user.saw(@foo) }.should change(@user.views, :count).by(1)
    end

    it "should not create a sight where one already exists (foo seen by a user)" do
      lambda { @foo.seen_by(@user); @foo.seen_by(@user) }.should change(@user.views, :count).by(1)
    end

    it "should have a timestamp" do
      @user.saw(@foo).seen_at.should_not be_nil
    end

    it "should update time when saw again" do
      # waiting for one second in specs is tiring 
      # @user.saw(@foo).tap{ sleep 1 }.seen_at.should_not be_eql(@user.saw(@foo).seen_at)
    end

    it "should not let a user see something which is not a foo" do
      lambda { @user.saw(SomethingElse.new) }.should raise_error
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

      @user.saw(@foo)
      @user.saw(@another_foo)

      @user.saw(@bar)
      @user.saw(@another_bar)

      @another_user.saw(@bar)
      @another_user.saw(@foo)
    end
    
    it "User should have named scopes to load seen foos and bars" do
      User.seen_foos.should_not be_empty
      User.seen_bars.should_not be_empty
    end

    it "Foo and Bar should have named scopes to load Users that sawed them" do
      Foo.seen.should_not be_empty
      Bar.seen.should_not be_empty
    end

    it "should find all user that have seen a foo" do
      User.which_saw(@foo).should have(2).items
      User.which_saw(@bar).should have(2).items
    end

    it "should find all foo and bars that have been seen by a user" do
      @user.saw?(@foo).should be_true
      @another_user.saw?(@foo).should be_true
      
      Foo.seen_by(@user).should have(2).items
      Bar.seen_by(@user).should have(2).items
    end

    it "should find all content seen by a user" do
      @user.viewed.should have(4).items
    end

    it "should find all users which saw a foo" do
      @foo.viewers.should have(2).items
    end
  end
  
  describe "Self references" do
    before :each do 
      @user = User.create valid_user_attributes
      @another_user = User.create valid_user_attributes
    end
    
    it "should let a user see another user" do
      @user.saw(@another_user)
      @user.saw?(@another_user).should be_true
      @another_user.should be_seen_by(@user)
    end
    
    it "should not let a user see himself" do
      @user.saw(@user).should be_nil
    end
  end
  
  describe 'serialization' do
    before :all do 
      @user = User.create valid_user_attributes
      @foo = Foo.create valid_foo_attributes
      @another_foo = Foo.create valid_foo_attributes
    end
    
    it "should have a seen flag when serialized with 'seen_by' option" do
      @user.saw(@foo)
      @foo.to_json(:seen_by => @user).should include('seen')
      @foo.to_json.should_not include('seen')
    end
    
    it "should have many seen flags when serializing a collection" do
      @user.saw(@foo)
      @user.saw(@another_foo)
      [@foo, @another_foo].to_json(:seen_by => @user).should include('seen')
    end
  end
end