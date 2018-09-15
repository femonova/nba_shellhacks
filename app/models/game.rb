class Game < ApplicationRecord
  belongs_to :player
  has_many :links
  include HTTParty


  self.import_games
    
  end



end


# 1. Fetch
