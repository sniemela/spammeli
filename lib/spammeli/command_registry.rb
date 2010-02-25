module Spammeli
  class InvalidCommandFormat < Exception
  end
  
  class UnknownCommand < Exception
  end
  
  class InvalidCommand < Exception
  end
  
  class CommandRegistry
    attr_reader :name, :params
    
    # Registered commands
    @@commands = {}
    
    def self.register(command_name, klass, options = {})
      command_name = command_name.to_s.downcase
      
      if options[:override]
        @@commands[command_name] = klass
      else
        @@commands[command_name] ||= klass
      end
    end
    
    def self.remove!(command)
      raise UnknownCommand unless @@commands.delete(command.to_s)
    end
    
    def self.commands
      @@commands
    end
    
    def self.clear
      @@commands = {}
    end
    
    def self.invoke(command_line)
      new(command_line).invoke
    end
    
    def initialize(command_line)
      raise InvalidCommandFormat unless command_line.strip =~ /^!\w+/
      @name, @params = parse_command_line(command_line)
    end
    
    def invoke
      raise InvalidCommand unless object.respond_to?(:invoke)
      object.invoke
    end
    
    def object
      raise UnknownCommand, name unless custom_command = @@commands[name]
      custom_command.new(params)
    end
    
    private
      def parse_command_line(command)
        match_data = command.strip.match(/^!(\w+)\s*(.*)/)
        params = match_data[2].nil? ? [] : match_data[2].split(/\s+/)
        [match_data[1], params]
      end
  end
end