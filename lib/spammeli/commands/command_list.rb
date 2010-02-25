module Spammeli
  module Commands
    # Command list commands returns a list of registered commands
    # in alphabetical order.
    #
    #   !commands # => command1, command2
    #
    class CommandList < Spammeli::Command
      def invoke
        Spammeli::CommandRegistry.commands.keys.sort.join(', ')
      end
    end
  end
  
  CommandRegistry.register(:commands, Commands::CommandList)
end