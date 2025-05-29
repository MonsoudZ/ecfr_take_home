class AddTitleNumberToSections < ActiveRecord::Migration[7.2]
  def change
    add_column :sections, :title_number, :integer
  end
end
