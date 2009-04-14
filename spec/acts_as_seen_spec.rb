require File.dirname(__FILE__) + '/spec_helper'

describe ActsAsSeen do
  before :each do
    @user = User.create(valid_user_attributes)
    @foo = Foo.create(valid_foo_attributes)
  end
  
  it "does something" do
    
  end
end