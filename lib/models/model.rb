require 'redis'
require 'time'
module HighDawn
  class TimelineModel
    def initialize(id)
      @hash={}
      @r=REDIS
      @tweets=[]
    end


    def save_timeline
      raise "blank id" if nil?
      @hash.each do |timestamp, bucket|
        bucket.each do |node|
          event=node[:event]
          follower=node[:follower]
          followee=node[:followee]
          key="users:#{id}:timestamp:#{timestamp.to_i}"
          #puts "saving #{key}"
          obj=node
          @r.sadd key, obj

          #add this to the list so I can find this key for lookup later
          @r.zadd "users:#{id}:timestamps", 0, timestamp.to_i
        end
      end
    end

    def self.find(id)
      u=User.new
      u.id=id
      u
    end



    def read_timeline(from=3.years.ago, to=Time.now, user_id, filter) #filter = :friends | :followers | :all

      zkey="users:#{user_id}:timestamps"
      all_ts=@r.zrange(zkey, 0, -1).collect(&:to_i)
      timestamps=get_range(all_ts, from.to_i, to.to_i)

      @hash=build_hash_from_redis(timestamps, user_id)

      if(filter==:all)
        return @hash
      end


      collection=FriendshipCollection.new

      @hash.each do |timestamp, bucket|
        if(from <= timestamp && timestamp <= to)
          bucket.each do |node|
            event=node[:event]
            follower=node[:follower]
            followee=node[:followee]

            f=Friendship.new ; f.timestamp=timestamp
            f.id=(follower==user_id)? followee : follower

            if((filter==:friends && follower==user_id ) || (filter==:followers && followee==user_id))
              case event
              when :follow then collection.push f
              when :unfollow then collection.delete f
              end
            end


          end
        end
      end
      collection
    end

    def build_hash_from_redis(timestamps, user_id)
      hash={}
      timestamps.each do |ts|
        key="users:#{user_id}:timestamp:#{ts}"
        resp=@r.smembers(key)
        hashes=deseralize_redis(resp)

        time=Time.at(ts)
        hash[time]=[] if hash[time].nil?
        hashes.each do |struct|
          hash[time].push struct
        end
      end
      hash
    end

    private
    def deseralize_redis(r)
      r.collect{|str| eval str}
    end

    def get_range(arry, s, e)
      a=[]
      arry.each do |i|
        a.push i if(s <= i && i <= e)
      end
      a
    end



  end
end
