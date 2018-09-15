class CreateGames < ActiveRecord::Migration[5.1]
  def change
    create_table :games do |t|
      t.datetime :date
      t.string :opponent
      t.integer :score
      t.integer :minutes
      t.string :fgma
      t.integer :points
      t.integer :rebounds
      t.integer :assists
      t.integer :steals
      t.integer :blocks
      t.integer :turnovers
      t.integer :metric

      t.timestamps
    end
  end
end
