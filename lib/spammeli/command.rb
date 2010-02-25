module Spammeli
  class Command
    attr_reader :name
    
    def initialize(name)
      @name = name
    end
  end
end