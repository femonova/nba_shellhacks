class AddYearsToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :years, :integer
  end
end
