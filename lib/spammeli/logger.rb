# encoding: utf-8
module Spammeli
  class Logger < ActiveSupport::BufferedLogger
    [:info, :debug, :warn, :error, :fatal, :unknown].each do |method|
      class_eval <<-RUBY_EVAL, __FILE__, __LINE__ + 1
        def #{method}(*args)
          puts args.first
          super
        end
      RUBY_EVAL
    end
  end
end