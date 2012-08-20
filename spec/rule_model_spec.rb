require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RuleModel do
  it "should save" do
    id=13223098

    resp=RuleModel.create(id, "retweet_all")
    resp.should eq true

    resp=RuleModel.read(id)
    resp.should eq ["retweet_all"]
  end

  it "should delet" do
    id=132232

    resp=RuleModel.create(id, "retweet_all")
    resp.should eq true

    resp=RuleModel.read(id)
    resp.should eq ["retweet_all"]

    RuleModel.delete(id, "retweet_all")

    resp=RuleModel.read(id)
    resp.should eq []
  end
end
