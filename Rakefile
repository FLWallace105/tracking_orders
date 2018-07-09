require 'dotenv'
Dotenv.load
require 'active_record'
require 'sinatra/activerecord/rake'

require_relative 'tracking_orders'

namespace :shopify_orders do
    
    desc "List Ellie Orders my_min='2018-04-14T00:00:00-04:00' my_max='2018-04-16T23:58:00-4:00'"
    task :list_ellie_orders, :my_min, :my_max do |t, args|
        my_min = args['my_min']
        my_max = args['my_max']
        ShopifyOrders::GetOrderInfo.new.get_ellie_orders(my_min, my_max)
    end 

    desc "List Marika Orders my_min='2018-04-14T00:00:00-04:00' my_max='2018-04-16T23:58:00-4:00'"
    task :list_marika_orders, :my_min, :my_max do |t, args|
        my_min = args['my_min']
        my_max = args['my_max']
        ShopifyOrders::GetOrderInfo.new.get_marika_orders(my_min, my_max)

    end

    desc "Read ellie tracking information CSV from Lawrence "
    task :read_ellie_tracking_csv do |t|
        ShopifyOrders::GetOrderInfo.new.read_ellie_csv
    end

    desc "Read marika tracking information CSV from Lawrence "
    task :read_marika_tracking_csv do |t|
        ShopifyOrders::GetOrderInfo.new.read_marika_csv
    end

    desc "Write one order fulfillment"
    task :write_one_order_fulfillment, :order_name do |t, args|
        order_name = args['order_name']
        ShopifyOrders::GetOrderInfo.new.write_one_order_fulfillment(order_name)
    end    


    #write_all_orders_fulfillment
    desc "Write all orders with fulfillment information"
    task :write_all_orders_fulfillment do |t|
        ShopifyOrders::GetOrderInfo.new.write_all_orders_fulfillment
    end

    #write_all_marika_orders_fulfillment
    desc "Write all marika orders with fulfillment information"
    task :write_all_marika_orders_fulfillment do |t|
        ShopifyOrders::GetOrderInfo.new.write_all_marika_orders_fulfillment
    end


end