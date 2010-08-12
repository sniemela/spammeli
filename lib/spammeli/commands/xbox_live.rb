# encoding: utf-8
require 'nokogiri'
require 'open-uri'

module Spammeli
  module Commands
    class GamerTag
      attr_reader :doc
      
      API_METHODS = %w(
        status info valid profile country score recent
      ).sort
      
      def initialize(doc)
        @doc = doc
      end
      
      def status
        return 'Presence information is invalid' unless valid_presence_info?
        @status ||= doc.at_css('PresenceInfo StatusText').text
      end
      
      def info
        return 'Presence information is invalid' unless valid_presence_info?
        @info ||= doc.at_css('PresenceInfo Info').text
      end
      
      def valid_presence_info?
        doc.at_css('PresenceInfo Valid').text != 'false'
      end

      def valid?
        doc.at_css('State').text == 'Valid'
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

    class XboxLive
      include Cinch::Plugin

      attr_reader :nick, :doc, :gamer

      XBOX_LIVE_API = 'http://xboxapi.duncanmackenzie.net/gamertag.ashx?GamerTag='

      match /xlive ([^\s]+)(\s[^\s]+)?/
      plugin "xlive"
      help "Syntax: !xlive <nick> [options]. Options: #{GamerTag::API_METHODS.join(', ')}"

      def configure(nick)
        if @nick = nick
          @doc = Nokogiri::XML(open(XBOX_LIVE_API + @nick))
          @gamer = GamerTag.new(@doc)
        end
      end
      
      def execute(m, nick, option)
        m.reply(gamer_info(nick, option))
      end

      def gamer_info(nick, option)
        configure(nick)
        return "Nick #{nick} is not valid" unless gamer.valid?

        if option
          option.strip!

          unless GamerTag::API_METHODS.include?(option)
            return "Option '#{option}' not supported. List available API methods: !help xlive" 
          end

          return gamer.send(option)
        end

        gamer.info
      end
    end
  end
end