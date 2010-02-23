require 'spec_helper'

describe Spammeli::Input do
  it "should determine that input is a user command" do
    input = Spammeli::Input.new('!weather vaasa')
    input.type.should == 'command'
  end
  
  it "should return true if input is a command" do
    input = Spammeli::Input.new('!tv mtv3')
    input.command?.should be_true
  end
end