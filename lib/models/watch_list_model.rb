module HighDawn
  module WatchListModel

    def read_followers(id)
      REDIS.smembers("tuid:#{id}:followers").map(&:to_i)||[]
    end

    def wsave
      @watch_list.each do |new_id|
        REDIS.sadd "user:#{id}:following", new_id #add somebody to my watch list
        REDIS.sadd "tuid:#{new_id}:followers", id #reverse lookup
      end
    end

    def wread
      key="user:#{id}:following"
      resp=REDIS.smembers key
      resp.map(&:to_i)
    end

    def save_queue(id, queue)
      queue_key="user:#{id}:pending_tweet_list"
      # p "saving #{queue.length} tweets to the queue"
     
      queue.each do |item|
         # p "#{queue_key}=#{item.to_json}"
        REDIS.rpush queue_key, item.to_json
      end
    end

    def read_queue(id)
      queue_key="user:#{id}:pending_tweet_list"
      arr=REDIS.lrange(queue_key, 0, -1).collect do |json|
        HighDawn::Tweet.from_json(json)
      end
      arr
    end

  end

end
