class AddOrderTotalToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :order_total, :float
  end
end
