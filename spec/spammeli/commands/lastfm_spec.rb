require 'spec_helper'

describe (Lastfm = Spammeli::Commands::Lastfm) do
  it "should show help message if parameters are empty" do
    Lastfm.new([]).invoke.should == 'Syntax: !lastfm [user/artist] [name] [options]'
  end
  
  it "should show help message for user param" do
    Lastfm.new(['user']).invoke.should == 'Syntax: !lastfm user [name] [options]. Options: lovedtracks, recenttracks, systemrecs, topartists, toptracks'
  end
end