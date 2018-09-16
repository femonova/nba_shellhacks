# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180916110012) do

  create_table "career_averages", force: :cascade do |t|
    t.integer "player_id"
    t.string "points"
    t.string "rebounds"
    t.string "assists"
    t.string "steals"
    t.string "blocks"
    t.string "turnovers"
    t.string "fgp"
    t.index ["player_id"], name: "index_career_averages_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "date"
    t.string "opponent"
    t.string "score"
    t.string "minutes"
    t.string "fgma"
    t.integer "points"
    t.integer "rebounds"
    t.integer "assists"
    t.integer "steals"
    t.integer "blocks"
    t.integer "turnovers"
    t.float "metric"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "player_id"
    t.string "boxscore"
    t.index ["player_id"], name: "index_games_on_player_id"
  end

  create_table "links", force: :cascade do |t|
    t.string "url"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "game_id"
    t.index ["game_id"], name: "index_links_on_game_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.string "team"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "headshot"
    t.integer "years"
    t.string "bballRefUrl"
  end

end
