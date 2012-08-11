require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe NonBro do
  it "should have followers" do
    u=HighDawn::User.new(id=61922)
    u.add_friend(1)
    u.add_friend(2)
    u.save
    u.non_bros.length.should eq 2

    #now I want to target this user and add them
    #to my watch list in hopes of engadgeing them
    #w/ usefully comments, etc and getting them
    #to follow me back

    u.watch_list= [u.non_bros[0].id, u.non_bros[1].id]
    u.watch_list.length.should eq 2
    
    #NOW assume I got a tweet from id=1, I should be able to reverse lookup 61992

    nb=HighDawn::NonBro.new(u.non_bros[0].id) #1
    followers = nb.followers
    followers.length.should eq 1
    followers.first.should eq id
  end
end
