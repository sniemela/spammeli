require 'spec_helper'

describe (Mathematic = Spammeli::Commands::Mathematic) do
  it "should calculate numbers" do
    formula = "(2 + 2) * 3 - 2".split(' ')
    
    Mathematic.new(formula).invoke.should == 10
  end
  
  it "should support math functions" do
    formula = "sqrt(1) * 2".split(' ')
    Mathematic.new(formula).invoke.should == 2.0
  end
  
  it "should complain about illegal characters" do
    formula = "Math.sqrt(1) * 2".split(' ')
    Mathematic.new(formula).invoke.should == "The formula contains some illegal characters"
  end
end