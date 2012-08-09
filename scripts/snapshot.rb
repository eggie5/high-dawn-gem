require 'ap'
require_relative '../lib/models/twitter_user'
require 'rubygems'
require 'logger'
require_relative '../lib/models/user'

module HighDawn

  class Snapshot
    def self.snapshot
      begin
        REDIS
      rescue NameError
        raise "Could not connect to redis instance. Please instanciate 'REDIS' with redis instance. (REDIS is undefined)"
      end

      twitter=TwitterUser.new
      user = User.new twitter.client.user.id

      b_friends=twitter.friends
      b_followers=twitter.followers
      diffs = user.diff(b_friends, b_followers)
      #save
      user.apply_diff(diffs)
    end

  end #end class

end#module
