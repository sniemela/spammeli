# encoding: utf-8

require 'spec_helper'

describe (Weather = Spammeli::Commands::Weather) do
  it "should not raise invalid byte sequence" do
    weather = Weather.new(['helsinki'])
    weather.stub!(:invoke).and_return("Räntää")
    lambda { weather.invoke }.should_not raise_error(ArgumentError)
  end
  
  it "should not raise invalid uri" do
    weather = Weather.new(['lappajärvi'])
    weather.stub!(:invoke).and_return("")
    lambda { weather.invoke }.should_not raise_error(URI::InvalidURIError)
  end
end