module Spammeli
  class Logger < ActiveSupport::BufferedLogger
    [:info, :debug, :warn, :error, :fatal, :unknown].each do |method|
      define_method(method) do |*args|
        puts args.first
        super
      end
    end
  end
end