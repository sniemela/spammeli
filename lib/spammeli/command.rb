module Spammeli
  class Command
    attr_reader :params
    
    class << self  
      def inherited(klass)
        ::Spammeli::CommandRegistry.register(klass.command_name, klass)
        super
      end
    end
    
    def initialize(params = [])
      @params = params
    end
    
    def self.command_name
      self.to_s.downcase
    end
  end
end