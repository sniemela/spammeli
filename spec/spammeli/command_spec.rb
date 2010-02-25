require 'spec_helper'

describe (Command = Spammeli::Command) do
  context "when created" do
    it "should return the command name" do
      command = Command.new('lastfm')
      command.name.should == 'lastfm'
    end
  end
end