require 'json'

module HighDawn
  class Tweet
    attr_accessor :timestamp, :message, :to_id
    def initialize(message)
      @message=message
    end
    def self.create(id, m)
      t=Tweet.new m
      t.to_id=id
      t
    end
    def self.from_json(json_str)
      msg=JSON.parse json_str
      Tweet.create msg["to_id"], msg["message"]
    end
  end
end
