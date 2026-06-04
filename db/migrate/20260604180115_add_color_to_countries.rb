class AddColorToCountries < ActiveRecord::Migration[8.1]
  def change
    add_column :countries, :color, :string
  end
end
