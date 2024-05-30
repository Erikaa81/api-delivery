class AddDeletedToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :deleted, :boolean, default: false
  end
end
