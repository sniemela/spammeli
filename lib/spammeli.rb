# encoding: utf-8

require 'active_support'

module Spammeli
  autoload :Command,         'spammeli/command'
  autoload :CommandRegistry, 'spammeli/command_registry'
  autoload :Config,          'spammeli/config'
  autoload :Irc,             'spammeli/irc'
  autoload :Version,         'spammeli/version'
end

require 'spammeli/commands'