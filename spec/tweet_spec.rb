require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ap'
include HighDawn

describe Tweet, "#create" do
  it "should work" do
    t=Tweet.create tuid: 7505382, text: "I love my fans!"
    t.class.should eq Tweet
    t.tuid.should eq 7505382
    t.text.should eq "I love my fans!"
  end
end

describe Tweet, "#save" do
  it "should save" do
    t=Tweet.create tuid: id=1234214, text: "I am tweet!"
    t.save(id, t)

    #asset it saved
    key="user:#{id}:tweets"
    my_tweets=REDIS.smembers key
    my_tweets.length.should eq 1
    tweet= Marshal::load my_tweets.first
    tweet.tuid.should eq id
    tweet.text.should eq "I am tweet!"

  end
end

describe Tweet, "#retweet?" do
  it "should be a retweet" do
    t=Tweet.create tuid: id=1234214, text: "RT I am tweet!"
    t.retweet?.should eq true
  end
  it "should not be a retweet" do
    t=Tweet.create tuid: id=1234214, text: "I am tweet!"
    t.retweet?.should eq false
  end
end
