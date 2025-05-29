class CreateChapters < ActiveRecord::Migration[7.2]
  def change
    create_table :chapters do |t|
      t.string :identifier
      t.string :label
      t.integer :ecfr_title_id
      t.integer :position

      t.timestamps
    end
  end
end
