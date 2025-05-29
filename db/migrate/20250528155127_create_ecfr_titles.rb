class CreateEcfrTitles < ActiveRecord::Migration[7.2]
  create_table :ecfr_titles do |t|
    t.integer  :number,            null: false
    t.string   :name,              null: false
    t.date     :latest_amended_on
    t.date     :latest_issue_date
    t.date     :up_to_date_as_of
    t.boolean  :reserved,          default: false
    t.datetime :last_synced_at

    t.timestamps
  end

  add_index :ecfr_titles, :number, unique: true
  add_index :ecfr_titles, :latest_amended_on
  add_index :ecfr_titles, :reserved
end

