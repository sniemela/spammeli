# encoding: utf-8

require 'active_support'

module Spammeli
  autoload :Channel,         'spammeli/channel'
  autoload :Command,         'spammeli/command'
  autoload :CommandRegistry, 'spammeli/command_registry'
  autoload :Config,          'spammeli/config'
  autoload :Irc,             'spammeli/irc'
  autoload :Logger,          'spammeli/logger'
  autoload :Plugin,          'spammeli/plugin'
  autoload :Version,         'spammeli/version'
end

require 'spammeli/commands'