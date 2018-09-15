class Player < ApplicationRecord
  has_many :games

  def self.import_players
    teams = ['hawks','celtics','nets','hornets','bulls','cavaliers','mavericks','nuggets','pistons','warriors','rockets','pacers','clippers','lakers','grizzlies','heat','bucks','timberwolves','pelicans','knicks','thunder','magic','sixers','suns','blazers','kings','spurs','raptors','jazz','wizards']
    teams.each do |t|
      response = HTTParty.get("http://data.nba.net/json/cms/noseason/team/#{t}/roster.json")
      teamName = response['sports_content']['roster']['team']['team_city'] + " " + response['sports_content']['roster']['team']['team_nickname']
      response['sports_content']['roster']['players']['player'].each do |p|
        name = p['first_name'] +" "+ p['last_name']
        name = name.titleize.strip
        if Player.where(name: name).where(team: teamName).length == 0
          Player.create(name: name, team: teamName, position: p['position_short'])
        end
      end
    end
    # response = HTTParty.get('http://data.nba.net/json/cms/noseason/team/pistons/roster.json')
    # puts response.body, response.code, response.message, response.headers.inspect
  end
end
