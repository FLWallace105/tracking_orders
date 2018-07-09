#tracking_orders.rb
require 'shopify_api'
require 'dotenv'
require 'csv'
#Dotenv.load
require 'active_record'
require "sinatra/activerecord"
require_relative 'models/model'


module ShopifyOrders
    class GetOrderInfo

        def initialize
            Dotenv.load
            @apikey = ENV['SHOPIFY_API_KEY']
            @shopname = ENV['SHOPIFY_SHOP_NAME']
            @password = ENV['SHOPIFY_PASSWORD']

            @marika_key = ENV['MARIKA_API_KEY']
            @marika_shopname = ENV['MARIKA_SHOP_NAME']
            @marika_password = ENV['MARIKA_PASSWORD']

            @zobha_key = ENV['ZOBHA_API_KEY']
            @zobha_shopname = ENV['ZOBHA_SHOP_NAME']
            @zobha_password = ENV['ZOBHA_PASSWORD']

        end

        def get_marika_orders(my_min, my_max)
            ShopifyAPI::Base.site = "https://#{@marika_key}:#{@marika_password}@#{@marika_shopname}.myshopify.com/admin"
            order_count = ShopifyAPI::Order.count( created_at_min: my_min, created_at_max: my_max, status: 'any')
            puts "We have #{order_count} orders for Marika"
            MarikaShopifyOrder.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('marika_shopify_orders')


            page_size = 250
            pages = (order_count / page_size.to_f).ceil

            num_orders_need_fulfill = 0

            1.upto(pages) do |page|
                orders = ShopifyAPI::Order.find(:all, params: {limit: 250, created_at_min: my_min, created_at_max: my_max, status: 'any', page: page})
                orders.each do |myorder|
                    puts "-----------------"
                    puts myorder.name
                    puts "-----------------"
                    myline_items = myorder.attributes['line_items']
                    new_array = Array.new
                    myline_items.each do |myline|
                        id = myline.attributes['id']
                        variant_id = myline.attributes['variant_id']
                        title = myline.attributes['title']
                        quantity = myline.attributes['quantity']
                        sku = myline.attributes['sku']
                        product_id = myline.attributes['product_id']
                        pre_tax_price = myline.attributes['pre_tax_price']
                        name = myline.attributes['name']
                        myproperties = myline.attributes['properties']
                        prop_array = Array.new
                        myproperties.each do |myprop|
                            puts myprop.attributes.inspect
                            prop_array << myprop.attributes
                        end
                        my_hash = {"id" => id, "variant_id" => variant_id, "title" => title, "quantity" => quantity, "sku" => sku, "product_id" => product_id, "pre_tax_price" => pre_tax_price, "name" => name, "properties" => prop_array}


                        new_array << my_hash
                    end

                    puts "cancelled_at = #{myorder.cancelled_at}"
                    puts "Not cancelled = #{myorder.cancelled_at.nil?}"
                    if myorder.fulfillments == [] && (myorder.cancelled_at.nil?)
                        puts "NO TRACKING INFO SAVING ORDER TO DB"
                        puts "This order needs to be fulfilled: #{myorder.name}, #{myorder.email}"
                        num_orders_need_fulfill += 1
                        new_db_order = MarikaShopifyOrder.create(order_name: myorder.name, order_id: myorder.id, created_at: myorder.created_at, email: myorder.email, line_items: new_array )

                    end

                end
                puts "Done with page #{page}"
                puts "Sleeping 6 seconds"
                sleep 6
            end
            puts "Now we have #{num_orders_need_fulfill} orders to fulfill"
        end


        def get_ellie_orders(my_min, my_max)
            ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"
            order_count = ShopifyAPI::Order.count( created_at_min: my_min, created_at_max: my_max, status: 'any')
            puts "We have #{order_count} orders"
            EllieShopifyOrder.delete_all
            ActiveRecord::Base.connection.reset_pk_sequence!('ellie_shopify_orders')


            page_size = 250
            pages = (order_count / page_size.to_f).ceil

            1.upto(pages) do |page|
                orders = ShopifyAPI::Order.find(:all, params: {limit: 250, created_at_min: my_min, created_at_max: my_max, status: 'any', page: page})
                orders.each do |myorder|
                    puts "-----------------"
                    #puts myorder.inspect
                    puts "#{myorder.name}, #{myorder.email}, #{myorder.created_at}, #{myorder.id}"
                    puts myorder.fulfillments.inspect
                    if myorder.fulfillments == []
                        puts "NO TRACKING INFO"
                    end
                    myline_items = myorder.attributes['line_items']
                    new_array = Array.new
                    myline_items.each do |myline|
                        id = myline.attributes['id']
                        variant_id = myline.attributes['variant_id']
                        title = myline.attributes['title']
                        quantity = myline.attributes['quantity']
                        sku = myline.attributes['sku']
                        product_id = myline.attributes['product_id']
                        pre_tax_price = myline.attributes['pre_tax_price']
                        name = myline.attributes['name']
                        myproperties = myline.attributes['properties']
                        prop_array = Array.new
                        myproperties.each do |myprop|
                            puts myprop.attributes.inspect
                            prop_array << myprop.attributes
                        end
                        my_hash = {"id" => id, "variant_id" => variant_id, "title" => title, "quantity" => quantity, "sku" => sku, "product_id" => product_id, "pre_tax_price" => pre_tax_price, "name" => name, "properties" => prop_array}


                        new_array << my_hash
                        #puts myline.attributes.inspect
                        #puts ""

                    end
                    #new_line_items = myline_items.to_a
                    puts new_array.inspect
                    puts "cancelled_at = #{myorder.cancelled_at}"
                    puts "Cancelled_at value = #{myorder.cancelled_at.nil?}"
                    if myorder.fulfillments == [] && (myorder.cancelled_at.nil?)
                        puts "NO TRACKING INFO SAVING ORDER TO DB"
                    
                        new_db_order = EllieShopifyOrder.create(order_name: myorder.name, order_id: myorder.id, created_at: myorder.created_at, email: myorder.email, line_items: new_array )
                    else
                        puts "NOT SAVING TO DB IT IS CANCELLED OR HAS TRACKING INFO"
                        puts "Cancelled at = #{myorder.cancelled_at}"
                    end
                    puts "-----------------"
                end
                puts "Done with page #{page}"
                puts "Sleeping 6 seconds"
                sleep 6
            end

        end

        def ship_via_for_shopify(ref_id)
            case ref_id[0..2]
              when '940'
                via = 'USPS'
              when '612'
                via = 'FEDEXSP'
              when '405' || '737'
                via = 'FEDEX'
              when '165'
                via = 'APC'
              else
                via = 'Carrier Not Found'
            end
            via
          end



        def read_ellie_csv
            CSV.foreach('june_new_ellie_tracking.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
                #puts row.inspect
                order_name = row['WCNPO#']
                order_tracking_number = row['WCNTRK']
                tracking_company = ship_via_for_shopify(order_tracking_number)
                puts "#{order_name} -- #{order_tracking_number} -- #{tracking_company}"
                my_db_order = EllieShopifyOrder.find_by_order_name(order_name)
                if !my_db_order.nil?
                    
                    my_db_order.tracking_company = tracking_company
                    my_db_order.tracking_number = order_tracking_number
                    my_db_order.save!
                    puts my_db_order.inspect
                end

            end

        end

        def read_marika_csv
            CSV.foreach('june_new_marika_tracking.csv', :encoding => 'ISO-8859-1', :headers => true) do |row|
                #puts row.inspect
                order_name = row['WCNPO#']
                order_tracking_number = row['WCNTRK']
                next if order_tracking_number.nil?
                tracking_company = ship_via_for_shopify(order_tracking_number)
                puts "#{order_name} -- #{order_tracking_number} -- #{tracking_company}"
                my_db_order = MarikaShopifyOrder.find_by_order_name(order_name)
                if !my_db_order.nil?
                    
                    my_db_order.tracking_company = tracking_company
                    my_db_order.tracking_number = order_tracking_number
                    my_db_order.save!
                    puts my_db_order.inspect
                end

            end

        end




        def write_all_orders_fulfillment
            orders = EllieShopifyOrder.where("tracking_company is not null and is_tracking_updated = ?", false)

            start_time = Time.now

            orders.each do |myorder|
                
                puts "Updating fulfillment for: #{myorder.order_name}, #{myorder.tracking_company}, updated: #{myorder.is_tracking_updated}"
                
                my_current = Time.now

                write_one_order_fulfillment(myorder.order_name)

                duration = (my_current - start_time).ceil
                puts "Been running #{duration} seconds"
                if duration > 480
                    puts "Been running more than 8 minutes must exit"
                    exit
                  end
            end
        end

        def write_all_marika_orders_fulfillment
            orders = MarikaShopifyOrder.where("tracking_company is not null and is_tracking_updated = ?", false)

            start_time = Time.now

            orders.each do |myorder|
                
                puts "Updating fulfillment for: #{myorder.order_name}, #{myorder.tracking_company}, updated: #{myorder.is_tracking_updated}"
                
                my_current = Time.now

                write_one_marika_order_fulfillment(myorder.order_name)

                duration = (my_current - start_time).ceil
                puts "Been running #{duration} seconds"
                if duration > 480
                    puts "Been running more than 8 minutes must exit"
                    exit
                  end
            end
        end

        def write_one_marika_order_fulfillment(order_name)
            order_to_write = MarikaShopifyOrder.find_by_order_name(order_name)
            if !order_to_write.nil?
                line_items = order_to_write.line_items
                tracking_number = [order_to_write.tracking_number]
                tracking_company = order_to_write.tracking_company
                notify_customer = true
                order_id = order_to_write.order_id
                shipment_status = "confirmed"
                status = "success"


                #set up Shopify info
                ShopifyAPI::Base.site = "https://#{@marika_key}:#{@marika_password}@#{@marika_shopname}.myshopify.com/admin"

                fullfil = ShopifyAPI::Fulfillment.new(:order_id => order_id, :notify_customer => true, :tracking_numbers => tracking_number, :tracking_company => tracking_company)
                puts "new fulfill = #{fullfil.inspect}"
                fullfil.save

                sleep 4

                order_to_write.is_tracking_updated = true
                order_to_write.save

                #sleep 3



            else
                puts "Cannot write fulfillment information could not find order."
                
            end


        end


        def write_one_order_fulfillment(order_name)
            order_to_write = EllieShopifyOrder.find_by_order_name(order_name)
            if !order_to_write.nil?
                line_items = order_to_write.line_items
                tracking_number = [order_to_write.tracking_number]
                tracking_company = order_to_write.tracking_company
                notify_customer = true
                order_id = order_to_write.order_id
                shipment_status = "confirmed"
                status = "success"

                #set up Shopify info
                ShopifyAPI::Base.site = "https://#{@apikey}:#{@password}@#{@shopname}.myshopify.com/admin"

                fullfil = ShopifyAPI::Fulfillment.new(:order_id => order_id, :notify_customer => true, :tracking_numbers => tracking_number, :tracking_company => tracking_company)
                puts "new fulfill = #{fullfil.inspect}"
                fullfil.save

                sleep 4

                #my_order = ShopifyAPI::Order.find(order_id)

                #puts my_order.fulfillments.inspect
                #puts my_order.fulfillment_status.inspect
                order_to_write.is_tracking_updated = true
                order_to_write.save

                #sleep 3



            else
                puts "Cannot write fulfillment information could not find order."
                #EllieStaging app info for testing
                api_key = "cd3e02801e153912dbd123c156a11b12"
                api_password = "2c32cf402e5d0354fd679b5dcdb137d5"
                local_shop_name = "elliestaging"
                ShopifyAPI::Base.site = "https://#{api_key}:#{api_password}@#{local_shop_name}.myshopify.com/admin"
                my_order = ShopifyAPI::Order.find(525686898780)
                #526027620444
                #my_order = ShopifyAPI::Order.find(526027620444)
                #my_order.fulfillment_status = 'fulfilled'
                puts my_order.inspect
                puts my_order.fulfillments.inspect
                puts my_order.fulfillment_status.inspect
                

                #my_order.fulfillments.status = "success"
                #my_order.fulfillments.tracking_company = "FEDEX"
                #my_order.fulfillments.tracking_numbers = [1234567]
                #my_order.fulfillments_status = "fulfilled"
                local_line_items = [{"id": 1452222873658, "sku": "764204172542", "name": "Seeing Stars - 3 Items (Ships every 1 Months)", "title": "Seeing Stars - 3 Items (Ships every 1 Months)", "quantity": 1, "product_id": 1446660702266, "properties": [{"name": "charge_interval_frequency", "value": "1"}, {"name": "charge_interval_unit_type", "value": "Months"}, {"name": "leggings", "value": "L"}, {"name": "main-product", "value": "true"}, {"name": "product_collection", "value": "Seeing Stars - 3 Items"}, {"name": "referrer", "value": ""}, {"name": "shipping_interval_frequency", "value": "1"}, {"name": "shipping_interval_unit_type", "value": "Months"}, {"name": "sports-bra", "value": "L"}, {"name": "tops", "value": "L"}], "variant_id": 13422444281914, "pre_tax_price": "29.97"}]
                #my_order.fulfillments.line_items = local_line_items
                #my_order.save!
                #puts my_order.inspect

                my_temp_array = [{ "order_id" => 527116206172, "status" => "success", "tracking_company" => "FEDEX", "tracking_numbers" => [12345], "line_items" => local_line_items}].to_json

                #my_order.fulfillments = my_temp_array
                #my_order.save!
                #my_order.fulfillments.attributes[0]['notify_customer'] = true
                #my_order.fulfillments.attributes['status'] = "success"
                #my_order.fulfillments.attributes['tracking_company'] = 'FEDEX'
                #my_order.fulfillments.attributes['tracking_numbers'] = [1234]
                #my_order.fulfillments.attributes['line_items'] = my_temp_array

                #fullfil = ShopifyAPI::Fulfillment.new(:order_id => 526565245020,  :notify_customer => true, :tracking_numbers => [1234], :line_items => local_line_items )

                #fullfil.prefix_options = { :order_id => 526565245020 }

                #fullfil.save

                #o = Order.find(343434)
                #o.fulfillments << Fulfillment.new("tracking_number" => 123456)
                #o.save

                #my_order.fulfillments << ShopifyAPI::Fulfillment.new(:order_id => 526565245020, :notify_customer => true, :tracking_numbers => [1234, 909, 818], :tracking_company => "FEDEX", :line_items => local_line_items )

                #my_order.fulfillments << { "order_id" => 526565245020, "notify_customer" => false, "tracking_numbers" => [123, 456], tracking_company => "FEDEX"}
                puts "my_order.fulfillments = #{my_order.fulfillments.inspect}"
                #puts my_order.fulfillments.methods
                #my_order.save

                #new_fulfillment = shopify.Fulfillment({'order_id': order.id, 'line_items': order.line_items,'status': pending})
                #new_fulfillment.save()
                #new_fulfillment = ShopifyAPI::Fulfillment.new(:order_id => 526565245020, :notify_customer => true, :tracking_numbers => [123, 456], :line_items => local_line_items)
                #new_fulfillment.save
                fullfil = ShopifyAPI::Fulfillment.new(:order_id => 525686898780, :notify_customer => true, :tracking_number => 110, :tracking_company => "FEDEX")
                puts "new fulfill = #{fullfil.inspect}"
                fullfil.save
               


                my_order = ShopifyAPI::Order.find(525686898780)


                puts my_order.fulfillments.inspect
                puts my_order.fulfillment_status.inspect

            end


        end


    end
end