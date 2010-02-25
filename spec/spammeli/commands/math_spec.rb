require 'spec_helper'

describe (Math = Spammeli::Commands::Math) do
  it "should calculate numbers" do
    formula = "(2 + 2) * 3 - 2".split(' ')
    
    Math.new(formula).invoke.should == 10
  end
  
  it "should complain if formula contains illegal characters" do
    formula = "(2 + 2) * 2a - 2b.".split(' ')
    lambda { Math.new(formula).invoke }.should raise_error(ArgumentError)
  end
end