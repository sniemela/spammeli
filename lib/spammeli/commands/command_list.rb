# encoding: utf-8

module Spammeli
  module Commands
    # Command list commands returns a list of registered commands
    # in alphabetical order.
    #
    #   !commandlist # => command1, command2
    #
    class CommandList
      def invoke
        Spammeli::CommandRegistry.commands.keys.sort.join(', ')
      end
    end
  end
end