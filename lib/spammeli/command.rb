module Spammeli
  class Command
    attr_reader :params, :irc
    
    class << self  
      def inherited(klass)
        ::Spammeli::CommandRegistry.register(klass.command_name, klass)
        super
      end
    end
    
    def initialize(params = [], irc = nil)
      @params = params
      @irc = irc
    end
    
    def current_channel
      irc.input.channel if irc
    end
    
    def self.command_name
      self.name.split('::').last.downcase
    end
  end
end