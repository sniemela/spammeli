# encoding: utf-8

module Spammeli
  module Commands
    class Dummy < Spammeli::Command
      def invoke
        "This a dummy command that does nothing"
      end
    end
  end
end