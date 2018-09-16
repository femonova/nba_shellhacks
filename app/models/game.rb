class Game < ApplicationRecord
  belongs_to :player
  has_many :links
  include HTTParty
  include Nokogiri

  # Didn't finish
  def self.import_youtube_links
    Yt.configure do |config|
      config.api_key = 'AIzaSyD7FoEXrMZ7iUM4TAO3i067EJFcq0VGBdc'
    end

    videos = Yt::Collections::Videos.new
    Game.all.each do |g|
      next if g.points < 25 || g.metric < 20
      query = "#{g.player.name} #{g.points} Full Highlights #{g.date.strftime('%Y.%m.%d')}"
      puts "Looking for: #{query}"
      embed = videos.where(q: query, safe_search: "none").first.player.data['embedHtml']
      if embed
        embed = embed.split(" ")[3].gsub(/src=\"\/\//,'').gsub(/\"/,'')
        link = Link.new(url: embed, game_id: g.id)
        link.save!
      end
    end
  end

  # imports games
  def self.import_games
    Player.all.each do |p|
      puts "Working on: #{p.name}"
      if p.games.length >= 1
        next
      end

      totalGames = 0
      # Array that will hold top 15 games by game_score
      finalGames = []

      # Populate yearsArr with years the player has played. E.g. ["2018","2017",...]
      yearsArr = []
      numSeasons = p.years
      it = 0
      while numSeasons > 0
        yearsArr.push((Time.now - it*31557600).strftime("%Y"))
        numSeasons -= 1
        it+=1
      end

      #loop through each year
      yearsArr.each do |y|
        # define URL for that year
        url = "https://www.basketball-reference.com/players/#{p.bballRefUrl}/gamelog/#{y}/"
        puts "Scraping: #{url}"
        response = HTTParty.get(url, :verify => false)
        parsed = Nokogiri::HTML(response.body)

        # array that stores every game in season
        games = []


        # START PLAYOFF GAMES
        # loop through comments, find THE COMMENT
        # don't ask, it's 4am and I'm desperate
        i = 0
        the_comment = ""
        while true
          the_comment = parsed.xpath("//comment()")[i]
          #puts the_comment.text.length
          if the_comment && the_comment.text.length > 1000
            break
          else
            i += 1
            break if i == 50
          end
        end
        if the_comment && the_comment.text.length > 1000
          html_playoffs = the_comment.text
          parsed_playoffs = Nokogiri::HTML(html_playoffs)
          i = 0
          while i < parsed_playoffs.css("#pgl_basic_playoffs tbody tr").length
            row = parsed_playoffs.css("#pgl_basic_playoffs tbody tr")[i]
            reason = row.css("td[data-stat='reason']")[0]
            headerRow = row.css("th[aria-label='Rank']")[0]
            if !reason && !headerRow # If the row has stats in it (the player played) and it's not a heading row
              boxScoreUrl = "https://www.basketball-reference.com" + row.css("td[data-stat='date_game']")[0].children[0]['href']
              date = row.css("td[data-stat='date_game']")[0].text
              opponent = row.css("td[data-stat='opp_id']")[0].text
              score = row.css("td[data-stat='game_result']")[0].text
              minutes = row.css("td[data-stat='mp']")[0].text
              fgma = row.css("td[data-stat='fg']")[0].text + "-" + row.css("td[data-stat='fga']")[0].text
              rebounds = row.css("td[data-stat='trb']")[0].text
              assists = row.css("td[data-stat='ast']")[0].text
              steals =  row.css("td[data-stat='stl']")[0].text
              blocks =  row.css("td[data-stat='blk']")[0].text
              turnovers =  row.css("td[data-stat='tov']")[0].text
              points = row.css("td[data-stat='pts']")[0].text
              metric = row.css("td[data-stat='game_score']")[0].text
              game = Game.new(boxscore: boxScoreUrl, date: date, opponent: opponent, score: score, minutes: minutes, fgma: fgma, rebounds: rebounds, assists: assists, steals: steals, blocks: blocks, turnovers: turnovers, points: points, metric: metric, player_id: p.id)
              games << game
              totalGames += 1
            else
              #puts "Did not Play/Header Row"
            end
            i+=1
          end
        end
        # END PLAYOFF GAMES

        # loop over games in regular season
        i = 0
        while i < 86
          row = parsed.css("#pgl_basic tbody tr")[i]
          if row
            reason = row.css("td[data-stat='reason']")[0]
            headerRow = row.css("th[aria-label='Rank']")[0]
            if !reason && !headerRow # If the row has stats in it (the player played) and it's not a heading row
              boxScoreUrl = "https://www.basketball-reference.com" + row.css("td[data-stat='date_game']")[0].children[0]['href']
              date = row.css("td[data-stat='date_game']")[0].text
              opponent = row.css("td[data-stat='opp_id']")[0].text
              score = row.css("td[data-stat='game_result']")[0].text
              minutes = row.css("td[data-stat='mp']")[0].text
              fgma = row.css("td[data-stat='fg']")[0].text + "-" + row.css("td[data-stat='fga']")[0].text
              rebounds = row.css("td[data-stat='trb']")[0].text
              assists = row.css("td[data-stat='ast']")[0].text
              steals =  row.css("td[data-stat='stl']")[0].text
              blocks =  row.css("td[data-stat='blk']")[0].text
              turnovers =  row.css("td[data-stat='tov']")[0].text
              points = row.css("td[data-stat='pts']")[0].text
              metric = row.css("td[data-stat='game_score']")[0].text
              game = Game.new(boxscore: boxScoreUrl, date: date, opponent: opponent, score: score, minutes: minutes, fgma: fgma, rebounds: rebounds, assists: assists, steals: steals, blocks: blocks, turnovers: turnovers, points: points, metric: metric, player_id: p.id)
              games << game
              totalGames += 1

            else
              #puts "Did not Play/Header Row"
            end
          end
          i += 1
        end


        if y == '2018'
          games = games.sort_by {|g| g.metric }.reverse
          if p.years >= 5
            games = games[0..14]
          else
            games = games[0..9]
          end
          games.each do |g|
            finalGames.push(g)
          end
        else
          games = games.sort_by {|g| g.metric }.reverse
          if p.years >= 5
            games = games[0..14]
          else
            games = games[0..9]
          end
          combo = finalGames + games
          combo = combo.sort_by {|g| g.metric }.reverse
          if p.years >= 5
            combo = combo[0..14]
          else
            combo = combo[0..9]
          end
          finalGames = []
          combo.each do |g|
            finalGames.push(g)
          end
        end

      end
      p "Top #{finalGames.length} games in Career by Game Score:"
      finalGames.each do |g|
        p g.metric.to_s + " - " + g.date.to_s
        if Game.where(player_id: p.id).where(date: g.date).length == 0
          g.save!
        end
      end
      puts "Total Games Parsed: #{totalGames}"
    end
  end

  def self.import_urls #doesn't catch 29 of 464 players due to nicknames/weird URLs on BR's side. Still works. eg: Adds "a/anderju01" to Justin Anderson

    Player.all.each do |p|
      if p.bballRefUrl
        next
      end
      i = 0
      playerUrl = ""
      puts "Working on: #{p.name}"
      # define it to use as number in URL if name is taken
      it = 1
      # fetch the guess URL from the player's model
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
        # I am sorry for how ugly this code is but it's called a HACKathon for a reason.
        puts "Final #{p.name} URL: #{playerUrl.gsub(/https:\/\/www.basketball-reference.com\/players\//,'').gsub(/\/gamelog\/2018\//,'')}"
        p.update_attributes(bballRefUrl: playerUrl.gsub(/https:\/\/www.basketball-reference.com\/players\//,'').gsub(/\/gamelog\/2018\//,''))
      end
    end
  end

end
