require 'ap'
require_relative '../lib/models/twitter_user'
require 'rubygems'
require 'logger'
require_relative '../lib/models/user'

module HighDawn

  class Snapshot

    def self.snapshot
      begin
        REDIS
      rescue NameError
        raise "Could not connect to redis instance. Please instanciate 'REDIS' with redis instance. (REDIS is undefined)"
      end

      twitter=TwitterUser.new

      puts "---------------------"
      puts " "
      puts "Generating snapshot for #{twitter.client.user.screen_name} (#{twitter.client.user.id})"
      p (Twitter.rate_limit_status.remaining_hits.to_s + " Twitter API request(s) remaining this hour")
      u=User.new twitter.client.user.id

      #check if there are any changes from last snapshot -- if not skip
      a_friends=u.friends.ids
      a_followers=u.followers.ids

      b_friends=twitter.friends
      b_followers=twitter.followers

      new_friends=b_friends - a_friends
      new_followers=b_followers - a_followers

      unfriended = a_friends - b_friends
      lost_followers = a_followers - b_followers

      p "new friends: #{new_friends}"
      p "unfriended: #{unfriended}"
      p "new_followers: #{new_followers}"
      p "lost_followers: #{lost_followers}"


      if (new_friends+unfriended+new_followers+lost_followers).empty?
        p "No diff - returning"
        puts ""
        puts "---------------------"
        return
      end

      p "diff found - persisting changes"
      puts ""
      puts "---------------------"

      # persist
      new_friends.each do |nf|
        u.add_friend(nf)
      end

      new_followers.each do |nf|
        u.add_follower(nf)
      end

      unfriended.each do |uf|
        u.remove_friend(uf)
      end

      lost_followers.each do |lf|
        u.remove_follower(lf)
      end

      u.save

      self.cache_usernames(new_friends + new_followers)
    end

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

  end #end class

end#module
