class AddStatusToItemOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :item_orders, :status, :string, default: "nil"
  end
end
