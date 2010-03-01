require 'spec_helper'

describe (Lastfm = Spammeli::Commands::Lastfm) do
  it "should show help message if parameters are empty" do
    Lastfm.new([]).invoke.should == 'Syntax: !lastfm [user/artist] [name] [options]'
  end
end