require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'redis'
require 'ap'

describe TimelineModel do

  it "should build hash from redis" do
    u=User.new 61
    time=Time.now
    u.add_friend(time,1)
    u.add_friend(time,2)
    u.add_friend(3.days.ago,4)
    u.save

    before_hash=u.hash
    before_len=2
    before_hash.keys.length.should eq before_len

    #now assert that the correct hash is rebuild from redis
    m=TimelineModel.new u.id
    after_hash=m.build_hash_from_redis([time.to_i, 3.days.ago.to_i], u.id)
    after_len=after_hash.keys.length
    before_len.should eq after_len

    after_hash.should eq before_hash
  end

  it "should propery deseralize data structure from redis keys" do
    u=User.new 91
    t=110.days.ago
    tid=33
    u.add_friend(t, tid)
    u.save

    #this should populate a new hash from redis
    m=TimelineModel.new u.id
    timeline = m.read_timeline(3.years.ago, Time.now, u.id, :friends)
    timeline.class.should eq FriendshipCollection

    timeline.length.should eq 1
    timeline[0].id.should eq tid
    timeline[0].timestamp.to_i.should eq t.to_i
    timeline[0].tweets.length.should eq 0

  end

  it "should property seralize data structure to redis keys" do
    u=User.new 1
    t=97.days.ago
    u.add_friend(t,32)
    u.save

    #this is probalby a dumb test...
    r=REDIS
    membs = r.smembers "users:#{u.id}:timestamp:#{t.to_i}"
    f=membs.collect{|str| eval str }[0]
    f[:event].should eq :follow
    f[:follower].should eq u.id
    f[:followee].should eq 32


    u.add_follower(t,5)
    u.save

    a=r.smembers("users:#{u.id}:timestamp:#{t.to_i}").collect{|str| eval str}

    a[0][:event].should eq :follow
    a[0][:follower].should eq 5
    a[0][:followee].should eq u.id

    a[1][:event].should eq :follow
    a[1][:follower].should eq u.id
    a[1][:followee].should eq 32



  end


  describe Friendship do
    it "should work w/ set logic" do

      f1=Friendship.new
      f1.id=1
      f1.timestamp=10.days.ago

      f2=Friendship.new
      f2.id=1
      ts=5.days.ago
      f2.timestamp=ts

      f3=Friendship.new
      f3.id=2
      f3.timestamp=3.days.ago

      #this says i was friends with f1 at sample a
      #and I was frinds w/ f1 & f2 on sample b
      #now find the intersection. it should return f2
      a=[f1]
      b=[f2, f3]

      inter = b & a

      inter.length.should eq 1
      inter[0].id.should eq f2.id
      inter[0].timestamp.should eq f2.timestamp

    end


  end

end
