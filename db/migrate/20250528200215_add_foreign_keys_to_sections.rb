class AddForeignKeysToSections < ActiveRecord::Migration[7.2]
  def change
    add_column :sections, :part_id, :integer
    add_column :sections, :subpart_id, :integer
    
    add_index :sections, :part_id
    add_index :sections, :subpart_id
    
    add_foreign_key :sections, :parts
    add_foreign_key :sections, :subparts
  end
end
