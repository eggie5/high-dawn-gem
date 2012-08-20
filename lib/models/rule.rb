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
    
    def save
      RuleModel.save(user_id, action)
    end
    
    def read
      RuleModel.read(user_id)
    end
    
  end
end

