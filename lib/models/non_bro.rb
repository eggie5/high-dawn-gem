module HighDawn
  class NonBro
    include WatchListModel
    
    attr_accessor :id
    def initialize(id)
      @id=id
    end
    
    def followers
      read_followers(id)
    end
    
  end
end
