require 'spec_helper'

describe (Dummy = Spammeli::Commands::Dummy) do
  it "should return the dummy text when invoked" do
    Dummy.new.invoke.should == 'This a dummy command that does nothing'
  end
end