require 'json'

module HighDawn
  class Tweet
    attr_accessor :timestamp, :message, :to_id
    def initialize(message, ts=Time.now)
      @message=message
      @timestamp=ts
    end
    
    def self.create(id, m)
      t=Tweet.new m
      t.to_id=id
      t.timestamp=Time.now
      t
    end
    
    def self.from_json(json_str)
      msg=JSON.parse( json_str)
      
      id=msg["to_id"]||msg["uid"]
      txt= msg["message"]||msg["text"]
      Tweet.create id, txt
    end
    def retweet?
      ((message=~ /RT/)!=nil)
    end
  end
end
