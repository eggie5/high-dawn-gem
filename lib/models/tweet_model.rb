module HighDawn
  module TweetModel
    def ssave
      #persist tweets
      @tweets.each do |tweet|
        if !tweet.to_id.nil?
          REDIS.sadd "user:#{id}:tweets:to:#{tweet.to_id}", tweet.to_json
        end
        
        #always save in the users general tweet bucket
        REDIS.sadd "user:#{id}:tweets", tweet.to_json

      end
    end

    def rread(to)

      if to.is_a? Integer
        key="user:#{id}:tweets:to:#{to}"
      elsif to.nil?
        puts "getting all tweets for #{id}"
        key="user:#{id}:tweets"
      else
        raise "invalid arg: #{to}"
      end

      resp=REDIS.smembers key
      resp.collect{|obj| Tweet.from_json(obj)}
    end
  end
end
