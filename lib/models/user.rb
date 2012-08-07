require_relative 'model'
require_relative 'friendship'
require_relative 'watch_list_model'
require 'active_support/all'

module HighDawn

  class User < TimelineModel
    include TweetModel
    include WatchListModel
    
    attr_accessor :id
    attr_reader :hash
    def initialize(twitter_id)
      super
      @id=twitter_id
    end

    def add_friend(ts=Time.now, id)
      add(time: ts, follower: self.id, action: :follow, followee: id)
    end

    def remove_friend(ts=Time.now, id)
      add(time: ts, follower: self.id, action: :unfollow, followee: id)
    end

    def add_follower(ts=Time.now, id)
      add(time: ts, follower: id, action: :follow, followee: self.id)
    end

    def remove_follower(ts=Time.now, id)
      add(time: ts, follower: id, action: :unfollow, followee: self.id)
    end

    #addes node to in-memory hash
    def add(options={})
      ts=options[:time].to_i
      struct={  event: options[:action],
        follower: options[:follower],
      followee: options[:followee] }

      @hash[ts]=[] if @hash[ts].nil?

      @hash[ts].push struct
    end


    def followers=(followers)
      @followers=followers
    end

    def bros(options={})
      from=options[:from] || 3.years.ago
      to=options[:to] || Time.now

      friends=friends(from: from, to: to)
      followers=followers(from: from, to: to)

      inter=(friends & followers)
      f=FriendshipCollection.new()
      f.replace(inter)
      f
    end

    def non_bros(options={})
      from=options[:from] || 3.years.ago
      to=options[:to] || Time.now

      f=friends(from: from, to: to)
      b=bros(from: from, to: to)
      diff=(f - b)

      f=FriendshipCollection.new()
      f.replace(diff)
      f
    end

    def friends(options={})
      from=options[:from] || 3.years.ago
      to=options[:to] || Time.now

      read(from, to, self.id, :friends)
    end

    def friends=(friends)
      @friends=friends
    end

    def followers(options={})
      from=options[:from] || 3.years.ago
      to=options[:to] || Time.now

      read(from, to, self.id, :followers)
    end

    def timeline(options={})
      from=options[:from] || 3.years.ago
      to=options[:to] || Time.now

      read(from, to, self.id, :all)
    end

    def tweets=(new_tweets)
      @tweets=new_tweets
      ssave
    end

    #either get all tweets from this user or tweets targeting someone
    def tweets(to=nil)
      @tweets = rread(to)
    end
    
    def watch_list=(list)
      @watch_list=list
      wsave
    end
    
    def watch_list
      @watch_list=wread
    end

    #proxy to read timeline in model
    def read(from=3.years.ago, to=Time.now, user_id, filter)
      read_timeline(from, to, user_id, filter)
    end

    #proxy to save timeline in model
    def save
      save_timeline
    end
  end
end
