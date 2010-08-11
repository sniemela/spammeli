require 'spec_helper'
require 'socket'
require 'active_support/core_ext/string'

class Connection < TCPSocket
  attr_accessor :out, :in
  
  def initialize
    @out, @in = "", ""
  end
  
  def gets
    @in
  end
  
  def send(output, n)
    @out << output
  end
end

class MockIrc < Spammeli::Irc
  attr_accessor :connection, :channels
  
  def initialize(*args)
    super(*args)
    @connection = Connection.new
  end
  
  def connect!
  end
  
  def connected?
    true
  end
  
  def logger
    @logger ||= ActiveSupport::BufferedLogger.new(File.expand_path('../../../log/test.log', __FILE__))
  end
  
  def run!
    connection.gets.split("\n").each do |line|
      methods = receive(line)
      methods.each { |meth, args| broadcast_sync(meth, *args) }
    end
  end
end

describe (Irc = Spammeli::Irc) do
  before do
    @irc = MockIrc.new('irc.quakenet.org', 6667, 'spammeli', 'Anneli', ['#tk08'])
  end
  
  context "when created" do
    it "should initialize channels" do
      @irc.channels['#tk08'].is_a? Spammeli::Channel
      @irc.channels['#tk08'].name.should == '#tk08'
    end
  end
  
  context "updating users" do
    it "should update on names list" do
      @irc.connection.in << ":underworld2.no.quakenet.org 353 spammeli @ #tk08 :spammeli @tmPr\n"
      @irc.run!
      @irc.channels['#tk08'].users.should == ['spammeli', 'tmPr']
    end
    
    it "should update after someone joining channel" do
      @irc.connection.in << ":underworld2.no.quakenet.org 353 spammeli @ #tk08 :spammeli @tmPr\n"
      @irc.connection.in << ":soulcage!~soulcage@3e48e57b.adsl.multi.fi JOIN #tk08\n"
      @irc.run!
      @irc.channels['#tk08'].users.should == ['spammeli', 'tmPr', 'soulcage']
    end
    
    it "should update after someone parting channel" do
      @irc.connection.in << ":underworld2.no.quakenet.org 353 spammeli @ #tk08 :spammeli @tmPr\n"
      @irc.connection.in << ":soulcage!~soulcage@3e48e57b.adsl.multi.fi JOIN #tk08\n"
      @irc.connection.in << ":soulcage!~soulcage@3e48e57b.adsl.multi.fi PART #tk08 :Leaving...\n"
      @irc.run!
      @irc.channels['#tk08'].users.should == ['spammeli', 'tmPr']
    end
  end

  it "should send pong" do
    @irc.connection.in << "PING :123\n"
    @irc.run!
    @irc.connection.out.should == "PONG :123\n"
  end
  
  it "should join channels after the welcome message" do
    @irc.connection.in << ":wineasy2.se.quakenet.org 001 spammeli :Welcome to the QuakeNet IRC Network, spammeli\n"
    @irc.run!
    @irc.connection.out.should == "JOIN #tk08\n"
  end
  
  it "should invoke a command" do
    @irc.connection.in << ":tmPr!~tmpr@asd.fi PRIVMSG #tk08 :!dummy\n"
    
    sender = { :nick => 'tmPr', :user => '~tmpr', :host => 'asd.fi' }
    args = { :message => '!dummy', :channel => '#tk08' }
    @irc.should_receive(:irc_bot_command_event).with(@irc, sender, args)
    
    @irc.run!
  end
end