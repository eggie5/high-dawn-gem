require_relative 'tweet_model'
require 'time'

module HighDawn
  class FriendshipCollection < Array

    def ids
      self.collect{|friendship|friendship.id}
    end

    def make_hash(*arrays)
      hash = Hash.new

      arrays.each do |array|
        array.each_with_index do |key, i|
          hash[key] = key
        end
      end

      return hash
    end

    def convert(object)
      unless object.respond_to? :to_ary then
        raise TypeError, "cannot convert " + object.class.name + " into Array"
      end
      return object.to_ary
    end

    def &(other)
      other = convert other
      new = Array.new
      hash = make_hash other

      self.each do |key|
        value = hash.delete key
        if value == key
          if key.timestamp.to_i > value.timestamp.to_i
            new << key
          else
            new << value
          end
        end
      end

      return new
    end

  end

  class Friendship
    include TweetModel
    attr_accessor :timestamp, :id

    def initialize()
      super(0)
      @tweets=[]
    end

    def tweets(options={}) #filter=:all | :id
      @tweets = read_tweets(id, options)
    end

    def create_tweet(options={})
      options.merge!(to_id: id)
      tweet=Tweet.create(options)
      @tweets.push tweet
      tweet.save(options[:tuid], tweet)
    end


    def eql?(o)
      self==(o)
    end

    def hash
      prime = 31;
      result = 1;
      result = prime * result + ((id == nil) ? 0 : id.hash);
      result
    end

    def ==(o)
      id==o.id
    end
  end
end
