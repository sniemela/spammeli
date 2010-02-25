require 'spec_helper'

describe (CommandList = Spammeli::Commands::CommandList) do
  before :each do
    # Register dummy commands
    [mock('Lastfm', :name => 'lastfm'), mock('Weather', :name => 'weather'), mock('Math', :name => 'math')].each do |c|
      Spammeli::CommandRegistry.register(c.name, c)
    end
  end
  
  it "should return a list of registered commands" do
    CommandList.new.invoke.should == 'lastfm, math, weather'
  end
end