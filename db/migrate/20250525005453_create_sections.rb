class CreateSections < ActiveRecord::Migration[7.2]
  def change
    create_table :sections do |t|
      t.string :agency
      t.string :part
      t.string :section
      t.text :text
      t.integer :word_count
      t.string :checksum

      t.timestamps
    end
  end
end
