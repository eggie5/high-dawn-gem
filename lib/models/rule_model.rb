module HighDawn
  module RuleModel
    
    def self.create(user_id, rule)
      key="user:#{user_id}:rules"
      p "#{key}=#{rule}"
      REDIS.sadd key, rule.to_s
    end
    
    def self.delete(user_id, rule)
      key="user:#{user_id}:rules"
      p "#{key}=#{rule}"
      REDIS.srem key, rule.to_s
    end

    def self.read(user_id)
      key="user:#{user_id}:rules"
      REDIS.smembers key
    end
  end
end
