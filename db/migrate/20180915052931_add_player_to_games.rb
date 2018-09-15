class AddPlayerToGames < ActiveRecord::Migration[5.1]
  def change
    add_reference :games, :player, foreign_key: true
    add_reference :links, :game, foreign_key: true
  end
end
