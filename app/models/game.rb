class Game < ApplicationRecord
  belongs_to :player
  has_many :links
  include HTTParty
  include Nokogiri
  include Byebug

  def self.import_games

  end

  def self.import_urls #doesn't catch 29 of 464 players due to nicknames/weird URLs on BR's side
    Player.all.each do |p|
      if p.bballRefUrl
        next
      end
      i = 0
      playerUrl = ""
      puts "Working on: #{p.name}"
      # define it to use as number in URL if name is taken
      it = 1
      # fetch the URL from the player's model
      url = p.bballRefURL("2018", it)
      # get the ballref page
      response = HTTParty.get(url, :verify => false)
      # parse the response with Nokogiri
      parsed = Nokogiri::HTML(response.body)
      # define the number of words in player's name
      words_in_name = p.name.gsub(/Jr./, '').gsub(/III/, '').gsub(/II/, '').gsub(/IV/, '').split(" ").length
      # fetch the same number of words from header from bballref
      name_from_response = parsed.css('h1[itemprop=name]').text.split(" ")[0..words_in_name-1].join(" ")
      # while the player's name in our DB != the player's name from BBallRef, increment it and try again.
      if p.name.gsub(/Jr./, '').gsub(/III/, '').gsub(/II/, '').gsub(/IV/, '').strip == name_from_response
        puts "Found #{p.name}'s BBall Ref Page: #{url}"
        playerUrl = url
        puts "Final #{p.name} URL: #{playerUrl.gsub(/https:\/\/www.basketball-reference.com\/players\//,'').gsub(/\/gamelog\/2018\//,'')}"
        p.update_attributes(bballRefUrl: playerUrl.gsub(/https:\/\/www.basketball-reference.com\/players\//,'').gsub(/\/gamelog\/2018\//,''))
        next
      else
        puts "Did not find #{p.name}'s BBall Ref Page. Tried: #{url} | Compared: #{p.name.gsub(/Jr./, '').gsub(/III/, '').gsub(/II/, '').gsub(/IV/, '').strip} to #{name_from_response}"
        while true
          it += 1
          url = p.bballRefURL("2018", it)
          response = HTTParty.get(url, :verify => false)
          parsed = Nokogiri::HTML(response.body)
          words_in_name = p.name.gsub(/Jr./, '').gsub(/III/, '').gsub(/II/, '').gsub(/IV/, '').split(" ").length
          name_from_response = parsed.css('h1[itemprop=name]').text.split(" ")[0..words_in_name-1].join(" ")
          if p.name.gsub(/Jr./, '').gsub(/III/, '').gsub(/II/, '').gsub(/IV/, '').strip == name_from_response
            puts "Found #{p.name}'s BBall Ref Page: #{url}"
            playerUrl = url
            break
          else
            puts "Did not find #{p.name}'s BBall Ref Page. Tried: #{url} | Compared: #{p.name.gsub(/Jr./, '').gsub(/III/, '').gsub(/II/, '').gsub(/IV/, '').strip} to #{name_from_response}"
          end
          i += 1
          if i == 5
            puts "Went thru 5 iterations, did not get a hit."
            break
          end
        end
        puts "Final #{p.name} URL: #{playerUrl.gsub(/https:\/\/www.basketball-reference.com\/players\//,'').gsub(/\/gamelog\/2018\//,'')}"
        p.update_attributes(bballRefUrl: playerUrl.gsub(/https:\/\/www.basketball-reference.com\/players\//,'').gsub(/\/gamelog\/2018\//,''))
      end
    end
  end

end


# 1. Fetch
