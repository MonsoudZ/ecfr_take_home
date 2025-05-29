class CreateParts < ActiveRecord::Migration[7.2]
  def change
    create_table :parts do |t|
      t.string :identifier
      t.string :label
      t.integer :chapter_id
      t.integer :position
      t.string :agency

      t.timestamps
    end

    add_index :parts, :identifier
    add_index :parts, :chapter_id
  end
end 