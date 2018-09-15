json.extract! player, :id, :name, :team, :position, :created_at, :updated_at
json.url player_url(player, format: :json)
