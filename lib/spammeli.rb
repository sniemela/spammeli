# encoding: utf-8

module Spammeli
  autoload :Command,         'spammeli/command'
  autoload :CommandRegistry, 'spammeli/command_registry'
  autoload :Config,          'spammeli/config'
  autoload :Input,           'spammeli/input'
  autoload :Irc,             'spammeli/irc'
  autoload :Output,          'spammeli/output'
  autoload :Version,         'spammeli/version'
end

require 'spammeli/commands'