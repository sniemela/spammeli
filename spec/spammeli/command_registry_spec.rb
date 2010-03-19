require 'spec_helper'

class LastfmCommand
  attr_reader :name, :params
  
  def initialize(params = [], irc = nil)
    @name = 'lastfm'
    @params = params
  end
  
  def invoke
    if params.empty?
      "lastfm invoked"
    else
      "lastfm invoked with #{params.join(' ')}"
    end
  end
end

class WeatherCommand
  attr_reader :name, :params
  
  def initialize(params = [], irc = nil)
    @name = 'weather'
    @params = params
  end
  
  def invoke
    "weather invoked"
  end
end

class InvalidCommand
  attr_reader :name, :params
  
  def initialize(params = [], irc = nil)
    @name = 'invalid'
    @params = params
  end
  
  # This class doesn't have the invoke method
end

describe (CommandRegistry = Spammeli::CommandRegistry) do
  before :each do
    CommandRegistry.clear
  end
  
  after(:each) do
    CommandRegistry.clear
  end
  
  context "when created" do
    it "should raise if invalid command format" do
      lambda { CommandRegistry.new('invalid command') }.should raise_error(Spammeli::InvalidCommandFormat)
    end
    
    it "should not raise if command format is valid" do
      lambda { CommandRegistry.new('!tv mtv3') }.should_not raise_error(Spammeli::InvalidCommandFormat)
    end
    
    it "should parse a command and parameters" do
      command = CommandRegistry.new('!lastfm tempra recent')
      command.name.should == 'lastfm'
      command.params.should == ['tempra', 'recent']
      
      command = CommandRegistry.new('!weather   vaasa     tomorrow   ')
      command.name.should == 'weather'
      command.params.should == ['vaasa', 'tomorrow']
      
      command = CommandRegistry.new('!weather')
      command.name.should == 'weather'
      command.params.should == []
    end
  end
  
  context "when register a command" do
    it "should work" do
      CommandRegistry.register(:lastfm, LastfmCommand)
      CommandRegistry.commands['lastfm'].should == LastfmCommand
    end
    
    it "should not override registered command with the same name" do
      CommandRegistry.register(:lastfm, LastfmCommand)
      CommandRegistry.commands['lastfm'].should == LastfmCommand
      
      CommandRegistry.register(:lastfm, WeatherCommand)
      CommandRegistry.commands['lastfm'].should_not == WeatherCommand
    end
    
    it "should override a registered command by forcing" do
      CommandRegistry.register(:lastfm, LastfmCommand)
      CommandRegistry.commands['lastfm'].should == LastfmCommand
      
      CommandRegistry.register(:lastfm, WeatherCommand, :override => true)
      CommandRegistry.commands['lastfm'].should == WeatherCommand
    end
  end
  
  context "when invoking a command" do
    it "should work" do
      CommandRegistry.register(:lastfm, LastfmCommand)
      CommandRegistry.invoke('!lastfm').should == 'lastfm invoked'
      CommandRegistry.invoke('!lastfm tempra recent').should == 'lastfm invoked with tempra recent'
    end
    
    it "should raise if the command does not exist" do
      lambda { CommandRegistry.invoke('!does_not_exist') }.should raise_error(Spammeli::UnknownCommand)
    end
    
    it "should raise if the command does not have the invoke method" do
      CommandRegistry.register(:invalid, InvalidCommand)
      lambda { CommandRegistry.invoke('!invalid')}.should raise_error(Spammeli::InvalidCommand)
    end
  end
  
  context "when removing" do
    it "should remove a command" do
      CommandRegistry.register(:lastfm, LastfmCommand)
      CommandRegistry.commands.length.should == 1

      CommandRegistry.remove!(:lastfm)
      CommandRegistry.commands.length.should == 0
    end
    
    it "should complain if the command doesn't exist" do
      CommandRegistry.commands.length.should == 0
      lambda { CommandRegistry.remove!(:lasfm) }.should raise_error(Spammeli::UnknownCommand)
    end
  end
  
  it "should rename the registered command" do
    CommandRegistry.register(:itunes, LastfmCommand)
    CommandRegistry.commands['itunes'].should == LastfmCommand
    CommandRegistry.commands['lastfm'].should be_nil
    
    CommandRegistry.rename!(:itunes, :lastfm)
    CommandRegistry.commands['itunes'].should be_nil
    CommandRegistry.commands['lastfm'].should == LastfmCommand
  end
end