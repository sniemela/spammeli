# encoding: utf-8
require 'nokogiri'
require 'open-uri'

module Spammeli
  module Commands
    class Weather < Spammeli::Command
      attr_reader :doc, :city
      
      GOOGLE_API_URL = 'http://www.google.com/ig/api?hl=fi&weather='
      
      def configure
        @doc = Nokogiri::XML(open(GOOGLE_API_URL + extract_all_scandic(params.first))) if params.length > 0
        @city = @doc.at_css('city')[:data] if @doc
      end
      
      def invoke
        return help if !doc || params.first == 'help'
        
        value = if params.length == 2
          forecast_conditions(params.last)
        else
          current_conditions
        end
        
        value = "#{city}: #{value}" if city
      end
      
      def help
        "Syntax: !weather location [day]"
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
        
        def forecast_conditions(day)
          day_forecast = doc.css('weather forecast_conditions').select do |f|
            f.at_css('day_of_week')[:data] == day.to_s.downcase
          end.first
          
          temp_low = day_forecast.at_css('low')[:data]
          temp_high = day_forecast.at_css('high')[:data]
          condition = day_forecast.at_css('condition')[:data]
          
          value = "#{temp_low}/#{temp_high}"
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
