require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ap'
include HighDawn


describe User do
  
  it "should add friend then from should follow back" do
    u=User.new uid=893
    add_time=1.day.ago
    id=9999
    u.add_friend(add_time, id)
    u.save
    
    u.bros.length.should eq 0
    
    follow_time=3.hours.ago
    u.add_follower(follow_time, id)
    u.save
    
    bros=u.bros
    bros.length.should eq 1
    bro=bros.first
    bro.timestamp.to_i.should eq follow_time.to_i #should be time they followed me back
    bro.id.should eq id
  end
  
  it "should get follower and then follow him back" do 
    u=User.new uid=2399
    follow_time=10.hours.ago
    id=1
    u.add_follower(follow_time, id) #kristy followed me
    u.save
    
    u.bros.length.should eq 0
    
    add_time=4.hours.ago # 6 hours later I follow her back -- this is the time we become bros!
    u.add_friend(add_time, id) #
    u.save
    
    bros=u.bros
    bros.length.should eq 1
    bro=bros.first
    bro.timestamp.to_i.should eq add_time.to_i #should be time I followed them back
  end
  
  it 'should have a timeline of events' do 
    u=User.new 24321
    (1..10).each do |i|
      u.add_friend(i.days.ago, i)
    end
    (1..10).each do |j|
      u.add_follower((j+20).days.ago, j+20)
    end
    u.save
    
    u.friends.length.should eq 10
    u.followers.length.should eq 10
    u.hash.length.should eq 20
    last_hash = u.hash
    
    #NOW load diff instance and see if it's in the hash
    u=User.new 24321
    timeline=u.timeline
    timeline.class.should eq Hash
    timeline.length.should eq 20
    timeline.should eq last_hash
  end

  it 'should my followers between april and november' do
    u=User.new 881
    u.add_follower(5.days.ago, 888)
    u.save

    u.followers(from: 10.days.ago, to: 2.days.ago)
  end

  it "UC #3 - bro should have associated tweets" do
    u=user_with_bro_who_has_tweets

    bro=u.bros(to: Time.now).first

    #check for all tweets to this bro
    bro.tweets.length.should eq 0
  end

  it "UC #2 - should show date someone followed me" do
    u=User.new 88
    u.add_friend(10.days.ago,  4)
    u.add_friend(9.days.ago, 5)
    u.save
    u.friends.length.should eq 2
    u.followers.length.should eq 0

    new_follower={id:6, ts:20.days.ago}
    u.add_follower(new_follower[:ts], new_follower[:id])
    u.save
    #added a follower 5 days ago

    u.followers.length.should eq 1
    follower = u.followers.first
    follower.id.should eq new_follower[:id]

    follower.timestamp.day.should eq new_follower[:ts].day


  end

  it "UC #1 - should show when somebody became a bro" do
    u=User.new 25
    u.add_friend(10.days.ago, 2)
    u.add_friend(8.days.ago, 3)
    u.add_friend(6.days.ago, 4)
    u.save

    #no bros at first
    u.bros.length.should eq 0
    #now follow me back to make 3 a bro
    id=3; at=5.days.ago
    u.add_follower(at, id)
    u.save

    u.bros.length.should eq 1

    bro=u.bros.first
    bro.id.should eq id
    bro.timestamp.strftime("%Y.%m.%d").should eq at.strftime("%Y.%m.%d")

  end

  it "should show current bros" do
    u=User.new 231
    u.add_friend( 4)
    u.add_friend( 5)
    u.save

    u.bros.length.should eq 0


    u.add_follower(id1=4)
    u.add_follower(id2=5)

    u.save

    bros=u.bros

    bros.length.should eq 2

  end

  it "should show current non-bros" do
    u=User.new 1242
    u.add_friend(3.days.ago, 4)
    u.add_friend(2.days.ago, 5)
    u.add_follower(1.days.ago, 4)
    u.save

    nbs=u.non_bros()

    nbs.length.should eq 1
    nbs[0].id.should eq 5
  end


  it "should add/remove followers" do
    u=User.new 9324
    u.add_follower(3.days.ago, 2)
    u.add_follower(2.days.ago,  3)
    u.add_follower(1.day.ago,   5) # a day ago
    u.add_follower(4) #now
    u.save

    u.followers.length.should eq 4

    u.remove_follower(4)
    u.remove_follower(5)
    u.remove_follower(3)
    u.remove_follower(2)
    u.save

    u.followers.length.should eq 0

  end

  it "should have a current list of friends" do
    u=get_user4();

    u.friends.length.should eq 8

  end


  it "should get a list of friends/followers on certain date" do
    u=User.new 123239
    u.add_friend(3.days.ago, 2)
    u.remove_friend(2.days.ago, 2) #unfollow
    u.add_friend(1.day.ago, 5) # a day ago
    u.add_friend(4) #now
    u.save

    u.friends(to: 3.days.ago).length.should eq 1 # accumulated collection as of 3 days ago
    u.friends(to: 2.days.ago).length.should eq 0
    u.friends(to: 1.day.ago).length.should eq 1

    friends= u.friends(to: Time.now) # accumulated collection as of NOW

    friends.ids.should eq [5,4]

  end
  
  it "should return FriendshipCollection for non-bros call" do
    u=User.new 1242
    u.non_bros.class.should eq FriendshipCollection
  end
end

describe User do
  it "should get a collection of users at a certain point in time" do
    t=User.new 234

    t.add(time: 3.days.ago, followee: 2, action: :follow, follower: t.id)
    t.add(time: 2.days.ago, followee: 3, action: :follow, follower: t.id)
    t.add(time: 1.days.ago, followee: 4, action: :follow, follower: t.id)
    t.add(time: Time.now,   followee: 5, action: :follow, follower: t.id)
    t.save
    ########### end setup

    friends=t.read(3.years.ago, Time.now, t.id, :friends)
    friends.length.should eq 4
    friend=friends[0]
    friend.timestamp.day.should eq 3.days.ago.day
    friend.id.should eq 2
  end
end

describe User, "#add" do
  it "adds even to timeline" do
    u=User.new 21

    today=Time.now
    u.add(time: today, followee: 3, action: :follow, follower: 4)
    u.add(time: today, followee: 3, action: :unfollowed, follower: 5);
    u.save

    #timeline.length.should eq(2)

  end
end

def user1
  u=User.new 1
  u.add_friend(3.days.ago, 2)
  u.remove_friend(2.days.ago, 2) #unfollow
  u.add_friend(1.day.ago, 5) # a day ago
  u.add_friend(4) #now
  u.save
  u
end
