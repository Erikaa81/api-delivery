class AddDeletedToStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :deleted, :boolean, default: false
  end
end
