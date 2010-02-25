module Spammeli
  class Command
    attr_reader :name, :params
    
    class << self  
      def inherited(klass)
        ::Spammeli::CommandRegistry.register(klass.to_s.downcase, klass)
        super
      end
    end
    
    def initialize(params = [])
      @params = params
    end
  end
end