require 'json'

module HighDawn
  class Tweet
    include TweetModel
    attr_accessor :timestamp, :text, :to_id, :tuid
    def initialize(text, ts=Time.now)
      @text=text
      @timestamp=ts
    end

    def self.create(options={})
      t=Tweet.new options[:text], Time.now
      t.tuid=options[:tuid]
      t.to_id=options[:to_id]
      t
    end
    

    # def self.from_json(json_str)
    #   msg=JSON.parse( json_str)
    # 
    #   id=msg["to_id"]||msg["uid"]
    #   txt= msg["message"]||msg["text"]
    #   Tweet.create {tuid: id, text: txt}
    # end
    def retweet?
      ((message=~ /RT/)!=nil)
    end

    def ==(o)
      text==o.text && timestamp==o.timestamp && tuid==o.tuid
    end

  end
end
