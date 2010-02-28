# encoding: utf-8

require 'rubygems'

module Spammeli
  autoload :Command,         'spammeli/command'
  autoload :CommandRegistry, 'spammeli/command_registry'
  autoload :Input,           'spammeli/input'
  autoload :Irc,             'spammeli/irc'
  autoload :Output,          'spammeli/output'
end

require 'spammeli/commands'