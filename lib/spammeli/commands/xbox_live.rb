# encoding: utf-8
require 'nokogiri'
require 'open-uri'

module Spammeli
  module Commands
    class XboxLive
      attr_reader :nick, :doc, :gamer
      
      XBOX_LIVE_API = 'http://xboxapi.duncanmackenzie.net/gamertag.ashx?GamerTag='
      
      def configure
        if @nick = params.first
          @doc = Nokogiri::XML(open(XBOX_LIVE_API + @nick))
          @gamer = GamerTag.new(@doc)
        end
      end
      
      def invoke
        return help if params.empty? || nick == ""
        return "Nick #{nick} is not valid" if gamer.valid == "false"
        
        if params.length > 1
          option = params.last
          unless GamerTag::API_METHODS.include?(option)
            return "Method '#{option}' not supported. List available API methods: !xlive" 
          end
          
          return gamer.send(option)
        end
        
        gamer.info
      end
      
      def help
        help = "Syntax: !xlive nick [options]. Options: "
        help += GamerTag::API_METHODS.join(', ')
        help
      end
    end
    
    class GamerTag
      attr_reader :doc
      
      API_METHODS = %w(
        status info valid profile country score recent
      ).sort
      
      def initialize(doc)
        @doc = doc
      end
      
      def status
        @status ||= doc.at_css('PresenceInfo StatusText').text
      end
      
      def info
        @info ||= doc.at_css('PresenceInfo Info').text
      end
      
      def valid
        doc.at_css('PresenceInfo Valid').text
      end
      
      def profile
        doc.at_css('ProfileUrl').text
      end
      
      def country
        doc.at_css('Country').text
      end
      
      def score
        doc.at_css('GamerScore').text
      end
      
      def recent
        recentgames = doc.css('RecentGames XboxUserGameInfo')
        return "No recent games" if recentgames.empty?
        
        # Show only two recent
        recentgames = recentgames[0..1]
        
        result = ""
        recentgames.each_with_index do |game, i|
          name = game.at_css('Game Name').text
          total_score = game.at_css('TotalGamerScore').text
          gamer_score = game.at_css('GamerScore').text
          result += "#{i + 1}. #{name} Score: #{gamer_score}/#{total_score} "
        end
        result
      end
    end
  end
end