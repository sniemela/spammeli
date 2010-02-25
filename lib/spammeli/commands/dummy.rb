module Spammeli
  module Commands
    class Dummy
      attr_reader :name, :params
      
      def initialize(params = [])
        @name = 'dummy'
        @params = params
      end
      
      def invoke
        "This a dummy command that does nothing"
      end
    end
  end
  
  # Register this command
  CommandRegistry.register(:dummy, Commands::Dummy)
end