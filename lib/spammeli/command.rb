module Spammeli
  class Command
    attr_reader :name, :params
    
    class << self
      def inherited(klass)
        ::Spammeli::CommandRegistry.register(klass.to_s.downcase, klass)
        super
      end
    end
    
    def initialize(name, params = [])
      @name, @params = name, params
    end
  end
end