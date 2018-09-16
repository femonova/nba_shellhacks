class AddBballrefurlToPlayers < ActiveRecord::Migration[5.1]
  def change
    add_column :players, :bballRefUrl, :string
  end
end
