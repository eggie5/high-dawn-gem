require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Rule do 
  it "should save" do 
    user_id=93939132
    r=Rule.new user_id, Rule::REWTEET_ALL
    r.save
    
    rules=REDIS.smembers("user:#{user_id}:rules")
    rules.should eq ["retweet_all"]
  end
  
  it "should have many" do
    HighDawn::Rule::RULES.length.should eq 3
  end
end