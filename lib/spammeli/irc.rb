require 'socket'

module Spammeli
  class Irc
    attr_reader :server, :port, :connection, :channels, :nick, :realname
    
    class Parameter
      attr :name
      attr :required
      attr :colonize
      attr :list

      def initialize(newname, options={})
        @name = newname
        @required = options[:required] or true
        @colonize = options[:colonize] or false
        @list = options[:list] or false
      end
    end
    
    def self.param(name, options = {})
      Parameter.new(name, options)
    end
    
    # Valid IRC command names, mapped to information about their parameters.
    IRC_COMMANDS = {
      :pass => [ param('password') ],
      :nick => [ param('nickname') ],
      :user => [ param('user'), param('host'), param('server'), param('name') ],
      :oper => [ param('user'), param('password') ],
      :quit => [ param('message', :required => false, :colonize => true) ],
    
      :join => [ param('channels', :list => true), param('keys', :list => true) ],
      :part => [ param('channels', :list => true) ],
      :mode => [ param('channel/nick'), param('mode'), param('limit', :required => false), param('user', :required => false), param('mask', :required => false) ],
      :topic => [ param('channel'), param('topic', :required => false, :colonize => true) ],
      :names => [ param('channels', :required => false, :list => true) ],
      :list => [ param('channels', :required => false, :list => true), param('server', :required => false) ],
      :invite => [ param('nick'), param('channel') ],
      :kick => [ param('channels', :list => true), param('users', :list => true), param('comment', :required => false, :colonize => true) ],
    
      :version => [ param('server', :required => false) ],
      :stats => [ param('query', :required => false), param('server', :required => false) ],
      :links => [ param('server/mask', :required => false), param('server/mask', :required => false) ],
      :time => [ param('server', :required => false) ],
      :connect => [ param('target server'), param('port', :required => false), param('remote server', :required => false) ],
      :trace => [ param('server', :required => false) ],
      :admin => [ param('server', :required => false) ],
      :info => [ param('server', :required => false) ],
    
      :privmsg => [ param('receivers', :list => true), param('message', :colonize => true) ],
      :notice => [ param('nick'), param('message', :colonize => true) ],
    
      :who => [ param('name', :required => false), param('is mask', :required => false) ],
      :whois => [ param('server/nicks', :list => true), param('nicks', :list => true, :required => false) ],
      :whowas => [ param('nick'), param('history count', :required => false), param('server', :required => false) ],
    
      :pong => [ param('code', :required => false, :colonize => true) ]
    }
    
    def initialize(s, p, nick, realname, channels = [])
      @nick, @realname = nick, realname
      @server, @port, @connection = s, p, nil
      @joined = false
      
      @listeners = []
      @listeners << self
      
      @channels = {}
      channels.each { |c| @channels[c.to_s] = Channel.new(c.to_s) }
    end
    
    def logger
      @logger ||= Spammeli::Logger.new(File.expand_path('../../../log/spammeli.log', __FILE__))
    end
    
    def connect!
      @connection = TCPSocket.open(server, port) unless connected?
      authenticate
    end
    
    def connected?
      !@connection.nil? && !@connection.closed?
    end
    
    def join_to_channels
      if connected?
        send_output("JOIN #{channels.keys.join(',')}")
        @joined = true
      end
    end
    
    def authenticate
      if connected?
        send_output "USER #{nick} 8 * : #{realname}"
        send_output "NICK #{nick}"
      end
    end
    
    def send_output(output)
      logger.debug "=> Sending output\n\t#{output}"
      @connection.send("#{output}\n", 0)
    end
    
    def run!
      logger.info "Starting Spammeli...\nPress CTRL-C to terminate."
      connect!
      
      begin
        while line = connection.gets
          methods = receive(line)
          methods.each { |meth, args| broadcast(meth, *args) }
        end
      rescue Interrupt
      end
      
      terminate!
    end
    
    def terminate!
      logger.info "Exiting..."
      if connected?
        send_output("QUIT :quitmo!")
        @connection.close
      end
      Kernel.exit
    end
    
    def broadcast(method, *args)
      @listeners.each do |listener|
        Thread.new do
          begin
            listener.send(method, *args) if listener.respond_to?(method)
          rescue Exception => e
            logger.fatal "Something bad happened:\n#{e.inspect}"
          end
        end
      end
    end
    
    def broadcast_sync(method, *args)
      @listeners.each do |listener|
        begin
          listener.send(method, *args) if listener.respond_to?(method)
        rescue Exception => e
          logger.fatal "Something bad happened:\n#{e.inspect}"
        end
      end
    end
    
    def method_missing(meth, *args)
      if IRC_COMMANDS.include? meth
        param_info = IRC_COMMANDS[meth]
        params = Array.new
        param_info.each do |param|
          raise ArgumentError, "#{param.name} is required" if args.empty? and param.required
          arg = args.shift
          next if arg.nil? or arg.empty?
          arg = (param.list and arg.kind_of? Array) ? arg.map(&:to_s).join(',') : arg.to_s
          arg = ":#{arg}" if param.colonize
          params << arg
        end
        raise ArgumentError, "Too many parameters" unless args.empty?
        send_output "#{meth.to_s.upcase} #{params.join(' ')}"
      else
        super
      end
    end
    
    protected
      def irc_ping_event(irc, sender, args)
        args[:message].nil? ? pong : pong(args[:message])
      end
      
      def irc_privmsg_event(irc, sender, args)
        if args[:message] =~ /^!\w+/
          irc_bot_command_event(irc, sender, args)
        end
      end
      
      def irc_bot_command_event(irc, sender, args)
        options = { :irc => irc, :sender => sender, :args => args }
        output = CommandRegistry.invoke(args[:message], options)
        send_output "PRIVMSG #{args[:channel]} :#{output}"
      end
      
      def irc_join_event(irc, sender, args)
        if channel = @channels[args[:channel]]
          channel.join_user(sender)
        end
      end
      
      def irc_part_event(irc, sender, args)
        if channel = @channels[args[:channel]]
          channel.part_user(sender)
        end
      end
      
      # TODO: named responses
      def irc_001_response(irc, sender, recipient, args, msg)
        join_to_channels unless @joined
      end
      
      def irc_353_response(irc, sender, recipient, args, msg)
        if channel = @channels[args.last]
          channel.update_users!(msg)
        end
      end
    
    private
      def receive(line)
        logger.debug "<< " + line
        methods = {}
        
        if line =~ /^:(.+?)\s+NOTICE\s+(\S+)\s+:(.+?)[\r\n]*$/
          server, sender, msg = $1, $2, $3
          methods[:irc_server_notice] = [self, server, sender, msg]
          return methods
        elsif line =~ /^NOTICE\s+(.+?)\s+:(.+?)[\r\n]*$/
          sender, msg = $1, $2
          methods[:irc_server_notice] = [self, nil, sender, msg]
          return methods
        elsif line =~ /^:(.+)!(\S+?)@(\S+?)\s+([A-Z]+)\s+(.*?)[\r\n]*$/
          sender = { :nick => $1, :user => $2, :host => $3 }
          command, arg_str = $4, $5
        elsif line =~ /^(\w+)\s+:(.+?)[\r\n]*$/
          command, msg = $1, $2
        elsif line =~ /^:([^\s:]+?)\s+(\d+)\s+(.*?)[\r\n]*$/
          server, code, arg_str = $1, $2, $3
          arg_array, msg = split_out_message(arg_str)
          numeric_method = "irc_#{code}_response".to_sym
          
          # readable_method = "irc_#{server_type.event[code.to_i]}_response".to_sym if not code.to_i.zero? and server_type.event?(code.to_i)
          
          name = arg_array.shift
          methods[numeric_method] = [self, server, name, arg_array, msg]
          
          # meths[readable_method] = [ self, server, name, arg_array, msg ] if readable_method
          
          methods[:irc_response] = [self, code, server, name, arg_array, msg]
          return methods
        end
        
        if arg_str
          arg_array, msg = split_out_message(arg_str)
        else
          arg_array = Array.new
        end
        
        command = command.downcase.to_sym
        arguments = {}
        
        case command
        when :quit
          arguments = {}
        when :privmsg
          arguments = { :channel => arg_array[0] }
        when :join
          arguments = { :channel => (msg || arg_array[0]) }
          msg = nil
        when :part
          arguments = { :channel => arg_array[0] }
        when :ping
          arguments = { :server => arg_array[0] }
        end
        
        arguments.update(:message => msg)
        method = "irc_#{command}_event".to_sym
        methods[method] = [self, sender, arguments]
        methods[:irc_event] = [self, command, sender, arguments]
        return methods
      end
      
      def split_out_message(arg_str)
        if arg_str.match(/^(.*?):(.*)$/) then
          msg = $2
          arg_array = $1.strip.split(/\s+/)
          return arg_array, msg
        else
          # no colon in message
          return arg_str.strip.split(/\s+/), nil
        end
      end
  end
end