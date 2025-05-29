class CreateSubparts < ActiveRecord::Migration[7.2]
  def change
    create_table :subparts do |t|
      t.string :identifier
      t.string :label
      t.integer :part_id
      t.integer :position

      t.timestamps
    end

    add_index :subparts, :identifier
    add_index :subparts, :part_id
  end
end 