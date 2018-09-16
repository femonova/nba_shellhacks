class AddBoxscoreToGames < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :boxscore, :string
  end
end
