require 'spec_helper'

describe (Lastfm = Spammeli::Commands::Lastfm) do
  it "should show help message if parameters are empty" do
    Lastfm.new([]).invoke.should == 'Syntax: !lastfm <nick> <options>'
  end
  
  it "should show help message for nick" do
    Lastfm.new(['tmPr']).invoke.should == 'Syntax: !lastfm <nick> <options>. Options: lovedtracks, recenttracks, systemrecs, topartists, toptracks'
  end
end