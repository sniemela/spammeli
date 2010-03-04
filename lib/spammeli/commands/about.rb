module Spammeli
  module Commands
    class About < Spammeli::Command
      def invoke
        'Spammeli Irc Bot, powered by Ruby. Copyright 2010 Simo Niemelä.'
      end
    end
  end
end