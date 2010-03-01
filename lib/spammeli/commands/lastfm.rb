require 'nokogiri'
require 'open-uri'

module Spammeli
  module Commands
    class Lastfm < Spammeli::Command
      def invoke
        return help if params.empty?
      end
      
      def help
        "Syntax: !lastfm [user/artist] [name] [options]"
      end
    end
  end
end