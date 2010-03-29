module Spammeli
  module Commands
    class Plugins < Spammeli::Command
      def invoke
        plugins = Spammeli::Plugin.all.map { |plugin| plugin.plugin_name }
        
        if plugins.empty?
          "No plugins"
        else
          "Registered plugins: #{plugins.join(', ')}"
        end
      end
    end
  end
end