# encoding: utf-8

require 'spec_helper'

describe (About = Spammeli::Commands::About) do
  it "should show copyright and contributors" do
    About.new.invoke.should == "Spammeli #{Spammeli::Version::STRING}, powered by Ruby. Copyright 2010 Simo Niemelä."
  end
end