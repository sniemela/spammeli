require 'spec_helper'

describe (Math = Spammeli::Commands::Math) do
  it "should calculate numbers" do
    formula = "(2 + 2) * 3 - 2".split(' ')
    
    Math.new(formula).invoke.should == 10
  end
end