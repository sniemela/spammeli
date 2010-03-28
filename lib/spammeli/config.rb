require 'yaml'

module Spammeli
  class Config
    @@config = nil
  
    class << self
      def load
        @@config ||= YAML.load(File.open(File.expand_path('../../../config.yaml', __FILE__)))
      end

      def load!
        @@config = nil
        load
      end

      def get(key)
        load['spammeli'][key.to_s]
      end
      
      def channels
        if chans = get(:channels)
          chans.to_a.compact.map { |c| "#" + c.to_s.downcase }
        else
          []
        end
      end
    end
  end
end
