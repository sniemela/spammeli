require 'nokogiri'
require 'open-uri'

module Spammeli
  module Commands
    class Weather < Spammeli::Command
      attr_reader :doc, :city
      
      GOOGLE_API_URL = 'http://www.google.com/ig/api?hl=fi&weather='
      
      def initialize(params = [])
        super(params)
        @doc = Nokogiri::XML(open(GOOGLE_API_URL + extract_all_scandic(params.first))) if params.length > 0
        @city = @doc.at_css('city')[:data] if @doc
      end
      
      def invoke
        return help if !doc || params.first == 'help'
        
        value = case params.last
          when 'now'
            current_conditions
          else
            current_conditions
          end
        
        value = "#{city}: #{value}" if city
      end
      
      def help
        "Syntax: !weather location"
      end
      
      private
        def current_conditions
          current = doc.at_css('weather current_conditions')
          condition = current.at_css('condition')[:data]
          temp = current.at_css('temp_c')[:data]
          
          value = "#{temp}"
          value = "#{value} ja #{condition.downcase}" unless condition == ""
          value
        end
        
        def extract_all_scandic(param)
          chars = {'ö' => 'o', 'ä' => 'a'}
          new_parma = ''
          chars.each do |scandic, ascii|
            param = param.gsub(/#{scandic}+/, ascii)
          end
          param
        end
    end
  end
end