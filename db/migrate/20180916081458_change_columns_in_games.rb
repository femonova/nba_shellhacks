class ChangeColumnsInGames < ActiveRecord::Migration[5.1]
  def change
    change_column :games, :metric, :float
    change_column :games, :minutes, :string
    change_column :games, :score, :string
  end
end
