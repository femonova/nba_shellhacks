class Game < ApplicationRecord
  belongs_to :player
  has_many :links
  include HTTParty


  def self.import_games
    i = 0
    Player.all.each do |p|
      it = 1
      url = p.bballRefUrl("2018", it)
      response = HTTParty.get(url, :verify => false)
      puts "---------------------------------------------------", response.parsed_response

      break
    end
  end



end


# 1. Fetch
