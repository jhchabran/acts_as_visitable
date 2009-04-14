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
    lambda { @foo.seen_by(@user) }.should change(Sight, :count).by(1)
  end
  
  it "should let a user see a foo " do
    lambda { @user.saw(@foo) }.should change(Sight, :count).by(1)
  end
  
  it "should not create a sight where one already exists (user saw a foo)" do
    lambda { @user.saw(@foo); @user.saw(@foo) }.should change(Sight, :count).by(1)
  end
  
  it "should not create a sight where one already exists (foo seen by a user)" do
    lambda { @foo.seen_by(@user); @foo.seen_by(@user) }.should change(Sight, :count).by(1)
  end
  
  it "should not let a user see something which is not a foo" do
    lambda { @user.saw(SomethingElse.new) }.should raise_error
  end
  
end