module HighDawn
  module WatchListModel

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
  end
end
