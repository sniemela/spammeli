require 'nokogiri'
require 'open-uri'

module Spammeli
  module Commands
    class Lastfm < Spammeli::Command
      def invoke
        return help if params.empty?
        
        type, name, option = params[0], params[1], params[2]
        
        case type
        when 'user'
          LastfmUser.new(name, option).invoke
        else
          help
        end
      end
      
      def help
        "Syntax: !lastfm [user/artist] [name] [options]"
      end
    end
    
    class LastfmUser
      attr_reader :name, :option
      
      def initialize(name, option)
        @name, @option = name, option
      end
      
      def invoke
        return help unless name && option
      end
      
      def help
        "Syntax: !lastfm user [name] [options]. Options: recent"
      end
    end
  end
end