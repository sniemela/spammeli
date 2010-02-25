module Spammeli
  module Commands
    # Command list commands returns a list of registered commands
    # in alphabetical order.
    #
    #   !commands # => command1, command2
    #
    class CommandList   
      def initialize(params = [])
      end
      
      def invoke
        Spammeli::Command.commands.keys.sort.join(', ')
      end
    end
  end
  
  Command.register(:commands, Commands::CommandList)
end