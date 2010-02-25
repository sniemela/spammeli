# encoding: utf-8

module Spammeli
  autoload :CommandRegistry, 'spammeli/command_registry'
  autoload :Input,   'spammeli/input'
  autoload :Irc,     'spammeli/irc'
end

require 'spammeli/commands'