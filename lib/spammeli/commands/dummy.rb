# encoding: utf-8

module Spammeli
  module Commands
    class Dummy
      include Cinch::Plugin

      match 'dummy'

      def execute(message)
        message.reply 'This is a dummy command that does nothing.'
      end
    end
  end
end