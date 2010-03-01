require 'nokogiri'
require 'open-uri'

module Spammeli
  module Commands
    class Lastfm# < Spammeli::Command
      attr_reader :params
      
      API_URL = 'http://ws.audioscrobbler.com'
      
      def initialize(params = [])
        @params = params
      end
      
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
      attr_reader :name, :option, :doc
      
      API_METHODS = %w(
        recenttracks lovedtracks systemrecs
        toptracks topartists
      )
      
      def initialize(name, option)
        @name, @option = name, option
      end
      
      def invoke
        return help if !(name && option) || !API_METHODS.include?(option)
        begin
          self.send(option)
        rescue OpenURI::HTTPError
          "Resource not found"
        end
      end
      
      def help
        "Syntax: !lastfm user [name] [options]. Options: #{API_METHODS.join(', ')}"
      end
      
      private
        def toptracks
          xml = load_xml!
          tracks = xml.css('track name').to_a
          to_numbered_list(tracks)
        end
        
        def recenttracks
          load_rss_and_titles!
        end
        
        def lovedtracks
          load_rss_and_titles!('2.0')
        end
        
        def systemrecs
          load_rss_and_titles!
        end
        
        def topartists
          xml = load_xml!
          artists = xml.css('artist name').to_a
          to_numbered_list(artists)
        end
      
        def load_rss_and_titles!(version = "1.0")
          @doc = Nokogiri::XML(open("#{api_url}/#{version}/user/#{name}/#{option}.rss"))
          items = @doc.css('item title').to_a
          to_numbered_list(items)
        end
        
        def load_xml!(version = "2.0")
          @doc = Nokogiri::XML(open("#{api_url}/#{version}/user/#{name}/#{option}.xml"))
        end
        
        def api_url
          @api_url || Lastfm::API_URL
        end
        
        def to_numbered_list(items = [])
          i = 0
          items[0..1].inject('') { |result, item| result += "#{i + 1}. #{item.text} "; i += 1; result }
        end
    end
  end
end