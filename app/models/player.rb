class Player < ApplicationRecord
  has_many :games
  has_one :career_average
  include HTTParty

  def self.import_career_averages
    Player.all.each do |p|
      url = "https://www.basketball-reference.com/players/#{p.bballRefUrl}.html"
      response = HTTParty.get(url, :verify => false)
      parsed = Nokogiri::HTML(response.body)
      row = parsed.css("#per_game tfoot tr")[0]
      points = row.css("td[data-stat='pts_per_g']").text
      rebounds = row.css("td[data-stat='trb_per_g']").text
      assists = row.css("td[data-stat='ast_per_g']").text
      steals =  row.css("td[data-stat='stl_per_g']").text
      blocks = row.css("td[data-stat='blk_per_g']").text
      turnovers = row.css("td[data-stat='tov_per_g']").text
      fgp = row.css("td[data-stat='fg_pct']").text
      avg = CareerAverage.new(player_id: p.id, points: points, assists: assists, rebounds: rebounds, steals: steals, blocks: blocks, turnovers: turnovers, fgp: fgp)
      if !p.career_average
        avg.save!
      end
    end
  end

  def self.import_players
    teams = ['hawks','celtics','nets','hornets','bulls','cavaliers','mavericks','nuggets','pistons','warriors','rockets','pacers','clippers','lakers','grizzlies','heat','bucks','timberwolves','pelicans','knicks','thunder','magic','sixers','suns','blazers','kings','spurs','raptors','jazz','wizards']
    teams.each do |t|
      response = HTTParty.get("http://data.nba.net/json/cms/noseason/team/#{t}/roster.json")
      teamName = response['sports_content']['roster']['team']['team_city'] + " " + response['sports_content']['roster']['team']['team_nickname']
      response['sports_content']['roster']['players']['player'].each do |p|
        name = p['first_name'] +" "+ p['last_name']
        name = name.strip.gsub(/'/, '')
        if Player.where(name: name).where(team: teamName).length == 0 && p['years_pro'].to_i != 0
          Player.create(name: name, team: teamName, position: p['position_short'], years: p['years_pro'].to_i)
        end
      end
    end
  end

  def self.import_headshots
    Player.all.each do |p|
      lastName = p.last_name.split(" ").join("_").downcase
      firstName = p.first_name.downcase
      p lastName + "/" + firstName
      url = "https://nba-players.herokuapp.com/players/#{lastName}/#{firstName}"
      response = HTTParty.get(url, :verify => false)
      p response.body
      if response.body != "Sorry, that player was not found. Please check the spelling."
        p.update_attributes(headshot: url)
      else
        p.update_attributes(headshot: "/avatar.png")
      end
    end
  end

  def first_name
    return self.name.split(" ")[0]
  end

  def last_name
    return self.name.split(" ").drop(1).join(" ")
  end

  def bballRefURL(year, it)
    if self.last_name[0]
      letter = self.last_name[0].downcase
    end
    nameInUrl = self.last_name.split(' ').join('')[0..4].downcase + self.first_name[0..1].downcase + it.to_s.rjust(2, '0')
    nameInUrl = nameInUrl.split(' ').join('')
    url = "https://www.basketball-reference.com/players/#{letter}/#{nameInUrl}/gamelog/#{year}/"
    return url
  end
end
