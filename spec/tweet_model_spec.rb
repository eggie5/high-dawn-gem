require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ap'
include HighDawn
include TweetModel

describe TweetModel, "#save_tweets" do
  it "should save" do

    id = 9933991
    tweet=Tweet.create tuid: id, to_id: 1, text: "this tweet should save"
    save_tweets id, [tweet]

    #now load it from redis and compare
    tweet_from_redis=Marshal::load(REDIS.smembers("user:#{id}:tweets").first)
    tweet_from_redis.should eq tweet
  end

end

describe TweetModel, "#read_tweets" do
  it "should read all tweets" do
    id = 9933992
    tweet=Tweet.create(tuid: id, to_id: 2, text: "this tweet should read")
    tweet2=Tweet.create(tuid: id, to_id: 3, text: "this tweet should read")
    save_tweets(id, [tweet, tweet2])

    tweets=read_tweets(id)
    tweets.length.should eq 2
    tweets.include?(tweet).should eq true
  end

  it "should read tweets to particular user" do
    id = 9933993
    tweet=Tweet.create(tuid: id, to_id: 2, text: "this tweet should read")
    tweet2=Tweet.create(tuid: id, to_id: 3, text: "this tweet should read")
    tweet3=Tweet.create(tuid: id, to_id: 3, text: "this tweet should read")
    save_tweets(id, [tweet, tweet2, tweet3])

    tweets=read_tweets(id, to: 3)
    tweets.length.should eq 2
    tweets.include?(tweet).should eq false
    tweets.include?(tweet2).should eq true
    tweets.include?(tweet3).should eq true
    
    tweets=read_tweets(id, to:2)
    tweets.length.should eq 1
    tweets.include?(tweet).should eq true
  end
end
