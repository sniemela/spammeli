# encoding: utf-8

require 'thread'

module Spammeli
  class Channel
    attr_reader :name, :users
    
    def initialize(name)
      @name, @users = name, []
      @update_mutex = Mutex.new
    end
    
    def update_users!(users)
      @update_mutex.synchronize do
        @users = users.gsub(/@+/, '').split(/\s+/)
      end
    end
    
    def join_user(user)
      @update_mutex.synchronize do
        @users << user[:nick]
      end
    end
    
    def part_user(user)
      @update_mutex.synchronize do
        @users = @users.reject { |name| name == user[:nick] }
      end
    end
  end
end