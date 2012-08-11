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

          p "tuid:#{id}=#{screen_name}"
          p "#{url_key}=#{url}"

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
        key="user:#{id}:tweets"
      else
        raise "invalid arg: #{to}"
      end

      resp=REDIS.smembers key
      resp.collect{|obj| Tweet.from_json(obj)}
    end
  end
end
