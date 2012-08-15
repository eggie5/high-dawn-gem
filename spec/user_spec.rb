require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ap'
include HighDawn

# describe Timeline do
#   it "should have Friendships" do
#     timeline = Timeline.load
#     timeline.class.should eq Timeline
#     timeline.length.should eq 40
#     timeline.first.class.should eq TimelineEvent
#     timeline.first.timestamp.should eq 3.days.ago
#   end
#
#   it "should filter by user" do
#     u=User.find(23424)
#     u.timeline.class.should eq Timeline
#     u.timeline.friends.length.should eq 10
#     u.timeline.followers.length.should eq 9
#     u.timeline.bros.length.should eq 8
#     u.timeline.non_bros.length.should eq 6
#     u.timeline.bros.first.class.should eq Friendship
#     u.timeline.bros.first.timestamp.should eq 3.days.ago
#     tweets=u.timeline.bros.first.tweets
#     tweets.lenght.should eq 10
#     u.timeline.
#
#   end
# end

describe User do

  it "should add & remove friend in one instance" do
    #an example of this case is when, the snapshot
    #script runs and in that time perion from the last snapshot
    #you both added a friend and deleted a friend

    u=User.new 123454321
    now=Time.now
    u.add_friend(1)
    u.remove_friend(1)
    u.add_follower(1)
    u.remove_follower(1)
    u.save
    u.friends.length.should eq 0
    u.followers.length.should eq 0

    u=User.new 123454321
    now=Time.now
    u.add_friend(1)
    u.add_follower(1)
    u.save
    u.friends.length.should eq 1
    u.followers.length.should eq 1
  end

  it "should have a timeline of events" do
    u=User.new id=2229941
    u.add_friend(3.weeks.ago, 1)
    u.add_friend(2.weeks.ago, 2)
    rt=1.week.ago
    u.remove_friend(rt, 1)
    u.save
    timeline=u.timeline
    timeline.length.should eq 3
    timeline[timeline.keys.last].first[:event].should eq :unfollow
  end

  it "should add non_bro to watch list" do
    u=User.new id=32002
    u.add_friend(1)
    u.add_friend(2)
    u.save
    u.non_bros.length.should eq 2

    #now I want to target this user and add them
    #to my watch list in hopes of engadgeing them
    #w/ usefully comments, etc and getting them
    #to follow me back

    u.watch_list.push u.non_bros[0].id
    u.watch_list.push u.non_bros[1].id
    u.watch_list.length.should eq 2
    u.save

    #now check my watch list
    u=User.new id
    u.watch_list.length.should eq 2
    # p u.watch_list
    u.watch_list.include?(1).should eq true
    u.watch_list.include?(2).should eq true


  end

  it "should show all tweets sent" do
    u=User.new id=2839

    user_tweet = u.create_tweet(text: "this is a tweet from me, user: #{id}")
    u.tweets.length.should eq 1

    u.tweets.length.should eq 1

    #now add a bunch of tweet to people
    tweets=[]
    (1..10).each do |i|
      tweet=Tweet.create({tuid: id, to_id: i, text: "hello #{i}"})
      u.tweets.push tweet
    end

    u.save
    #tweets for that particular user
    u.tweets(to: 10).length.should eq 1

    #all tweets sent by me
    u.tweets.length.should eq 11

  end

  it "should have tweets" do
    u=User.new id=78901
    u.save
    u.tweets.length.should eq 0

    #add tweet
    time=Time.now
    tweet=Tweet.create(tuid: id, to_id: 1, text: "hello #{time.to_i}")
    u.tweets.push tweet
    u.save

    u.tweets(to: 1).length.should eq 1

    #now load new instance and see if it gets pulled from redis
    user=User.new id
    user.tweets(to: 1).length.should eq 1
    user.tweets(to: 1).first.text.should eq "hello #{time.to_i}"
    user.tweets.length.should eq 1
  end

  it "should send tweets to watch list member" do
    u=User.new id=99331
    #mock retweet of watch list memeber
    t=Tweet.create tuid: id, text: "RT @MittRomney Happy Birthday wishes to a great friend and Iowa's outstanding Lt. Gov. @KimReynoldsIA!"
    u.tweets.push t
    u.save
    u.tweets.length.should eq 1


  end

  it "should add a friend then from should follow back" do
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

  it 'should have followers between april and november' do
    u=User.new 881
    u.add_follower(Time.parse("April 1, 2011"), 888)
    u.save

    #there should be none in this timerange
    u.followers(from: Time.parse("April 2, 2011"), to: Time.parse("March 30, 2012")).length.should eq 0

    #not add one
    u.add_follower(Time.parse("June 20, 2011"), 1)
    u.save

    #there sholud be 1 in teh time range now
    u.followers(from: Time.parse("April 2, 2011"), to: Time.parse("March 30, 2012")).length.should eq 1

    #add one just outside the range
    u.add_follower(Time.parse("March 31, 2011"), 2)
    u.save

    #there sholud be 1 in teh time range now
    u.followers(from: Time.parse("April 2, 2011"), to: Time.parse("March 30, 2012")).length.should eq 1

  end

  it "UC #3 - bro should have associated tweets" do
    u=User.new id=199983
    u.add_friend 4
    u.add_friend 5
    #tweet 4 so he'll follow me back and be my bro
    u.add_follower 4 #bro - mock follow back
    u.save
    bro=u.bros().first
    tweet_time=Time.now
    bro.create_tweet tuid: id, text: m="@4 i am a message to one of my friends I want to follow back"

    #so I have one bro - let's explore how he became a bro
    # bro.tweets.length.should eq 1
    u.tweets(to: 4).length.should eq 1 #I only sent him one message on twitter

    #check for tweet w/ diff instance
    user=User.new id
    # user.bros.first.tweets(1).length.should eq 1
    #  user.bros.first.tweets(1).first.text.should eq m
    #  user.bros.first.tweets(1).first.timestamp.to_i.should eq tweet_time.to_i
  end

  it "should sent tweet to non-bro, then he becomes bro, then check if that message is still there" do
    u=User.new id=439914
    add_time=3.months.ago
    u.add_friend add_time, 1
    u.save

    u.non_bros.length.should eq 1
    non_bro=u.non_bros.first
    #now send him a message to try and get him to follow you back
    tweet=Tweet.create(tuid: id, text: "@1 hey you, follow me back!")
    tweet2=Tweet.create(tuid: id, text: "@1 i'll pay you to follow me. Aren't we bros???")

    #non_bro.create_tweet tuid: id, text: "@1 hey you, follow me back!"
    #non_bro.create_tweet tuid: id, text: "@1 i'll pay you to follow me. Aren't we bros???"
    u.create_tweet text: "@1 hey you, follow me back!", to_id: non_bro.id
    u.create_tweet text: "@1 i'll pay you to follow me. Aren't we bros???", to_id: non_bro.id

    u.tweets(to: non_bro.id).length.should eq 2

    #we convinced him to follow us back
    now=Time.now
    u.add_follower(now, 1)
    u.save
    u.bros.length.should eq 1
    bro=u.bros.first

    #when did he become my bro?
    bro.timestamp.to_i.should eq now.to_i
    #how many tweets did it take to convert him?
    u.tweets(to: bro.id).length.should eq 2
    # bro.tweets.length.should eq 2
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
    bro.timestamp.to_i.should eq at.to_i

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
    # u.remove_follower(2)
    u.save

    u.followers.length.should eq 1
    u.followers.first.id.should eq 2

    u=User.new 9324
    u.followers.length.should eq 1
    u.followers.first.id.should eq 2

    u.add_follower(1.minute.ago, 1234)
    u.save #2 and 1234
    u.followers.length.should eq 2

    u.add_friend(10.days.ago, 2)
    u.save

    u.friends.length.should eq 1
    u.followers.length.should eq 2

    u.add_friend(2.days.ago, 2342)
    u.add_friend(1.day.ago, 23424)
    u.add_friend(3.days.ago, 203820)
    u.remove_friend(23424)
    u.remove_follower(2)
    u.remove_friend(2342)

    u.save
    u.friends.length.should eq 2
    u.followers.length.should eq 1

    u.remove_friend(203820)
    u.remove_friend(2)
    u.save

    u.friends.length.should eq 0
    u.remove_follower(1234)
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
    friends.length.should eq 2
    friends.ids.should eq [5,4]

  end

  it "should return FriendshipCollection for non-bros call" do
    u=User.new 1242
    u.non_bros.class.should eq FriendshipCollection
  end

  it "should diff" do
    u=User.new 3651
    (1..4).each do |i|
      u.add_friend(i)
      u.add_follower(i)
    end
    u.save

    #from twitter
    friends=[1,2,3,4]
    followers=[1,2,3,4,5,6]
    h={:new_friends => [], :lost_friends => [], :new_followers => [5, 6], :lost_followers => []}

    u.diff(friends, followers).should eq h
  end

  it "should apply diff" do
    u=User.new 3651
    u.add_friend(1)
    u.add_friend(2)
    u.add_friend(3)
    u.add_friend(4)

    u.add_follower(1)
    u.add_follower(2)
    u.add_follower(3)
    u.add_follower(4)
    u.save

    #from twitter
    friends=[1,3,4,99]
    followers=[2,3,4,5,6]
    h={:new_friends => [99], :lost_friends => [2], :new_followers => [5, 6], :lost_followers => [1]}

    diff=u.diff(friends, followers)
    diff.should eq h

    #before diff is applied
    u.friends.length.should eq 4
    u.followers.length.should eq 4

    #apply diff and assert changes
    u.apply_diff diff

    u.friends.length.should eq 4
    u.followers.length.should eq 5

  end

  it "should have pending tweet queue" do
    u=HighDawn::User.new id=73337
    u.queue.length.should eq 0

    before_tweet=Tweet.create({tuid: id, to_id: 1, text:"I love all my fans, just rewteet me for a follow back -- Justin Beaver"})
    before_tweet_2= Tweet.create({tuid: id, to_id: 1, text: "To all my fans: I love you!"})
    u.queue << before_tweet
    u.queue << before_tweet_2
    u.save
    u.queue.length.should eq 2



    u=HighDawn::User.new id
    u.queue.length.should eq 2
    after_tweet=u.queue.first
    after_tweet.text.should eq before_tweet.text
    after_tweet.to_id.should eq 1
    after_tweet.tuid.should eq id

    u=HighDawn::User.new 39239
    u.queue.length.should eq 0
  end

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
    friend.timestamp.to_i.should eq 3.days.ago.to_i
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

    u.timeline.length.should eq(1)
  end


end

describe User, "#create_tweet" do
  it "should add tweet" do
    u=User.new id=1337
    u.tweets.length.should eq 0
    u.create_tweet text: "i'm new tweet text"
    u.tweets.length.should eq 1
  end
end
