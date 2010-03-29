module Spammeli
  class Plugin
    class_inheritable_accessor :plugin_name
    self.plugin_name = nil
    
    @@registered_plugins = []
    
    attr_reader :irc
    
    def initialize(irc)
      @irc = irc
      configure
    end
    
    def configure
      raise NotImplementedError
    end
    
    class << self
      def register_all!(irc)
        return unless respond_to?(:subclasses)
        
        subclasses.each do |plugin|
          plugin = plugin.constantize.new(irc)
          next if plugin.plugin_name.to_s.blank?
          @@registered_plugins << plugin
        end
      end
    end
  end
end
