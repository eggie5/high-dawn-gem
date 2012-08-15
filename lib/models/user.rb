require_relative 'model'
require_relative 'friendship'
require_relative 'watch_list_model'
require 'active_support/all'

module HighDawn

  class User < TimelineModel
    include TweetModel
    include WatchListModel

    attr_accessor :id, :queue
    attr_reader :hash
    def initialize(twitter_id)
      super
      @id=twitter_id
      @queue=[]
      @tweets=[]
      @watch_list=[]
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

    def create_tweet(options={})
      options.merge! tuid: id
      tweet=Tweet.create(options)
      @tweets.push tweet
      status=tweet.save(id, tweet)
      
      tweet if status
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

    #either get all tweets from this user or tweets targeting someone
    def tweets(options={})

      @tweets=(@tweets.empty? || (@last_tweets_options!=options)) ? @tweets=read_tweets(self.id, options) : @tweets
      @last_tweets_options=options
      @tweets
    end

    def watch_list
      (@watch_list.empty?) ? @watch_list=read_watchlist(id) : @watch_list
    end

    #proxy to read timeline in model
    def read(from=3.years.ago, to=Time.now, user_id, filter)
      read_timeline(from, to, user_id, filter)
    end

    #proxy to save timeline in model
    def save
      save_timeline
      save_queue(id, @queue) #in waitlist module
      save_tweets(id, @tweets)
      save_watchlist(id, @watch_list)
    end

    def queue
      (@queue.empty?) ? @queue=read_queue(id) : @queue
    end


    #for snapshot
    def diff(b_friends, b_followers)
      a_friends=friends.ids
      a_followers=followers.ids

      new_friends=b_friends - a_friends
      new_followers=b_followers - a_followers

      unfriended = a_friends - b_friends
      lost_followers = a_followers - b_followers

      diffs={
        new_friends: new_friends,
        lost_friends: unfriended,
        new_followers: new_followers,
      lost_followers: lost_followers}

      diffs

    end

    def apply_diff(diffs)
      new_friends = diffs[:new_friends]
      new_followers = diffs[:new_followers]
      unfriended = diffs[:lost_friends]
      lost_followers = diffs[:lost_followers]

      new_friends.each do |nf|
        add_friend(nf)
      end

      new_followers.each do |nf|
        add_follower(nf)
      end

      unfriended.each do |uf|
        remove_friend(uf)
      end

      lost_followers.each do |lf|
        remove_follower(lf)
      end

      save
      return diffs
    end
  end
end
