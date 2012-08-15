module HighDawn
  module TweetModel

    def self.cache_usernames(ids)
      #cache user names
      twitter=TwitterUser.new

      ids.each_slice(99).to_a.each do |ids_slice|
        users=twitter.client.friendships(ids_slice).map{|u| [u.screen_name, u.id] }

        users.each do |arr|
          id = arr[1]
          screen_name=arr[0]

          url=Twitter.user(id).profile_image_url
          url_key="tuid:#{id}:image_url"

          REDIS.pipelined do
            TweetModel::cache_id(id, screen_name)
            REDIS.set(url_key, url)
          end
        end
      end
    end

    def self.cache_id(id, screen_name)
      REDIS.set("tuid:#{id}", screen_name)
    end

    def save(id, tweet)
      s=Marshal::dump tweet
      
      if !tweet.to_id.nil?
        REDIS.sadd "user:#{id}:tweets:to:#{tweet.to_id}", s
      end

      #always save in the users general tweet bucket
      key="user:#{id}:tweets"
      REDIS.sadd key, s

    end

    def save_tweets(id, tweets)
      #persist tweets
      
      tweets.each do |tweet|
        s=Marshal::dump tweet
        
        if !tweet.to_id.nil?
          key="user:#{id}:tweets:to:#{tweet.to_id}"
          # p "#{key}=#{s}"
          REDIS.sadd key, s
        end

        #always save in the users general tweet bucket
        key="user:#{id}:tweets"
        #p "SADD #{key}=#{tweet.to_json}"
        
        REDIS.sadd key, s

      end
    end

    def read_tweets(id, options={})
      
      if options[:to]
        key="user:#{id}:tweets:to:#{options[:to]}"
      elsif options[:to].nil?
        key="user:#{id}:tweets"
      else
        raise "invalid arg: #{to}"
      end
      # p "SMEMBERS #{key}"

      resp=REDIS.smembers key
      resp.collect{|obj| tweet= Marshal::load(obj)}
    end
  end
end
