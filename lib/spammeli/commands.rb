Dir["#{File.dirname(__FILE__)}/commands/*.rb"].sort.each do |path|
  require "spammeli/commands/#{File.basename(path, '.rb')}"
end

require 'active_support/core_ext/string'

module Spammeli
  module Commands
    def self.load(*cmds)
      unless cmds.empty?
        cmds.map { |c| "Spammeli::Commands::#{c.classify}".constantize }
      else
        Dir["#{File.dirname(__FILE__)}/commands/*.rb"].map do |path|
          "Spammeli::Commands::#{File.basename(path, '.rb').classify}".constantize
        end
      end
    end
  end
end