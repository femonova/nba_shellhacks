class CreateCareerAverages < ActiveRecord::Migration[5.1]
  def change
    create_table :career_averages do |t|
      t.references :player, foreign_key: true
      t.string :points
      t.string :rebounds
      t.string :assists
      t.string :steals
      t.string :blocks
      t.string :turnovers
      t.string :fgp
    end
  end
end
