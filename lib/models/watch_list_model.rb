module HighDawn
  module WatchListModel

    def read_followers(id)
      key="tuid:#{id}:followers"
      REDIS.smembers(key).map(&:to_i)||[]
    end

    def save_watchlist(id, watch_list)
      watch_list.each do |new_id|
        REDIS.sadd "user:#{id}:following", new_id #add somebody to my watch list
        REDIS.sadd "tuid:#{new_id}:followers", id #reverse lookup
      end
    end

    def read_watchlist(id)
      key="user:#{id}:following"
      resp=REDIS.smembers key
      resp.map(&:to_i)
    end

    def save_queue(id, queue)
      queue_key="user:#{id}:pending_tweet_list"
     
      queue.each do |item|
        REDIS.rpush(queue_key, Marshal::dump(item))
      end
    end

    def read_queue(id)
      queue_key="user:#{id}:pending_tweet_list"
      arr=REDIS.lrange(queue_key, 0, -1).collect do |json|
        Marshal::load json
      end
      arr
    end

  end

end
