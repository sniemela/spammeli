# encoding: utf-8

module Spammeli
  module Commands
    class About < Spammeli::Command
      def invoke
        "Spammeli #{Spammeli::Version::STRING}, powered by Ruby. Copyright 2010 Simo Niemelä."
      end
    end
  end
end