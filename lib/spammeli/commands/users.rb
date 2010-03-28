module Spammeli
  module Commands
    class Users < Spammeli::Command
      def invoke
        channel.users.join(' ')
      end
    end 
  end
end