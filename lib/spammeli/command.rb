module Spammeli
  class Command
    attr_reader :params, :options

    class << self  
      def inherited(klass)
        ::Spammeli::CommandRegistry.register(klass.command_name, klass)
        super
      end
    end

    def initialize(params = [], options = {})
      @params = params
      @options = options
      configure
    end

    def configure
    end

    def current_channel
      ""
    end

    def irc
      @irc ||= options[:irc]
    end

    def sender
      @sender ||= options[:sender]
    end

    def channel
      @channel ||= irc.channels[options[:args][:channel]]
    end

    def self.command_name
      self.name.split('::').last.downcase
    end
  end
end