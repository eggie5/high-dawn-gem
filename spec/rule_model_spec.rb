require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RuleModel do
  it "should save" do
    id=13223098

    resp=RuleModel.save(id, "retweet_all")
    resp.should eq true
    
    resp=RuleModel.read(id)
    resp.should eq ["retweet_all"]
  end
end
