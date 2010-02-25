require 'spec_helper'

describe (Command = Spammeli::Command) do
  after :each do
    Spammeli::CommandRegistry.clear
  end
  
  context "when created" do
    it "should work without params" do
      command = Command.new
      command.params.should == []
    end
    
    it "should return params" do
      command = Command.new(['tempra', 'recent'])
      command.params.should == ['tempra', 'recent']
    end
  end
  
  it "should register automatically sub classes" do
    class TestCommand < Spammeli::Command
      def invoke
        # ...
      end
    end
    
    Spammeli::CommandRegistry.commands.length.should == 1
    Spammeli::CommandRegistry.commands['testcommand'].should == TestCommand
  end
end