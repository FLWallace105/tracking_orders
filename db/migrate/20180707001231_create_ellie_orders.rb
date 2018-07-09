class CreateEllieOrders < ActiveRecord::Migration[5.2]
  def up
    create_table :ellie_shopify_orders do |t|
      t.string :order_name
      t.bigint :order_id
      t.datetime :created_at
      t.string :email
      t.jsonb :line_items
      t.string :tracking_company
      t.string :tracking_number
      t.boolean :is_tracking_updated, default: false

    end
  end

  def down
    drop_table :ellie_shopify_orders
  end
end
