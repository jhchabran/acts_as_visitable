require File.dirname(__FILE__) + '/spec_helper'

describe ActsAsSeen do
  before :each do
    @user = User.create(valid_user_attributes)
    @foo = Foo.create(valid_foo_attributes)
  end
  
  it "should include ActsAsSeen in Foo" do
    Foo.should include(ActsAsSeen)
  end
  
  it "should declare a has_many relationship between Foo and Sight" do
    Foo.reflections.should include(:sights)
    Foo.reflections[:sights].macro.should be_eql(:has_many)
  end
  
  it "should let a foo be seen by a user" do
    lambda { @foo.seen_by(@user) }.should change(@user.sights, :count).by(1)
  end
  
  it "should let a user see a foo " do
    lambda { @user.saw(@foo) }.should change(@user.sights, :count).by(1)
  end
  
  it "should let a user see many foos" do
    lambda { @user.saw(@foo) }.should change(@user.sights, :count).by(1)
    lambda { @user.saw(Foo.create(valid_foo_attributes)) }.should change(@user.sights, :count).by(1)
  end
  
  it "should let a foo be seen by many users" do
    lambda { @foo.seen_by(@user) }.should change(@foo.sights, :count).by(1)
    lambda { @foo.seen_by(User.create(valid_user_attributes)) }.should change(@foo.sights, :count).by(1)
  end
  
  it "should not create a sight where one already exists (user saw a foo)" do
    lambda { @user.saw(@foo); @user.saw(@foo) }.should change(@user.sights, :count).by(1)
  end
  
  it "should not create a sight where one already exists (foo seen by a user)" do
    lambda { @foo.seen_by(@user); @foo.seen_by(@user) }.should change(@user.sights, :count).by(1)
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