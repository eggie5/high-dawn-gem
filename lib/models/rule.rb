module HighDawn

  class Rule
    attr_accessor :user_id, :action
    def initialize(user_id, action)
      @user_id=user_id
      @action=action
    end

    REWTEET_ALL="retweet_all"
    RETWEET_SELECTED="retweet_selected"
    REPLY="reply"
    RULES=[REWTEET_ALL, RETWEET_SELECTED, REPLY]

    def save
      RuleModel.save(user_id, action)
    end

    def self.read(user_id)
      rule_strs=RuleModel.read(user_id)
      rules=[]
      rule_strs.each do |rule_str|
        rules.push Rule.new(user_id, rule_str)
      end
      rules
    end

    def ==(o)
      user_id==o.user_id && action==o.action
    end

  end
end
