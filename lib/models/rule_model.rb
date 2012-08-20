module HighDawn
  module RuleModel
    
    def self.save(user_id, rule)
      key="user:#{user_id}:rules"
      REDIS.sadd key, rule.to_s
    end

    def self.read(user_id)
      key="user:#{user_id}:rules"
      REDIS.smembers key
    end
  end
end
