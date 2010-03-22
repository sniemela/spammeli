require 'spec_helper'

class Connection
  attr_accessor :out, :in
  
  def initialize
    @out, @in = "", ""
  end
  
  def gets
    @in
  end
  
  def send(output, n)
    out << output
  end
end

class MockIrc < Spammeli::Irc
  attr_accessor :connection
  
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
    if line = connection.gets
      methods = receive(line)
      methods.each { |meth, args| broadcast(meth, *args) }
    end
  end
end

p Spammeli::CommandRegistry.commands

describe (Irc = Spammeli::Irc) do
  before do
    @irc = MockIrc.new('irc.quakenet.org', 6667, 'spammeli', 'Anneli', ['#tk08'])
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
    @irc.should_receive(:irc_bot_command_event).with(@irc, "!dummy")
    @irc.run!
  end
end