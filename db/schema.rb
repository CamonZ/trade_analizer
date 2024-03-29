# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120806233225) do

  create_table "executions", :force => true do |t|
    t.date     "date"
    t.datetime "time"
    t.string   "symbol"
    t.integer  "shares"
    t.float    "price"
    t.string   "side"
    t.string   "contra"
    t.integer  "liquidity"
    t.float    "profit_and_loss",   :default => 0.0
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
    t.integer  "executions_day_id"
  end

  create_table "executions_days", :force => true do |t|
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.date     "date"
    t.float    "profit_and_loss"
    t.float    "wins"
    t.float    "losses"
    t.float    "wins_average"
    t.float    "losses_average"
    t.float    "win_percentage"
    t.float    "losses_percentage"
    t.string   "best_stock"
    t.string   "worst_stock"
  end

end
