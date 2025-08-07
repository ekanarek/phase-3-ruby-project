#!/usr/bin/env ruby

require 'rest-client' 
require 'json' 
require_relative './api_client'

class CLIInterface 
  def initialize 
    @api_client = APIClient.new 
  end

  def display_menu 
    puts "\n=== Shopping Tracker CLI ==="
    puts "1. View all receipts"
    puts "2. View all purchased items"
    puts "3. Add a new receipt"
    puts "q. Quit"
    print "\nEnter your choice: "
  end

  def run 
    puts "Welcome to the Shopping Tracker CLI!" 
    puts "This application connects to your Sinatra API."
    puts "Make sure your API server is running on http://localhost:9292"
    puts 

    loop do 
      display_menu 
      choice = gets.chomp.downcase 

      case choice 
      when '1'
        view_all_receipts 
      when '2'
        view_all_items 
      when '3'
        create_new_receipt 
      when 'q', 'quit', 'exit' 
        puts "Bye!" 
        break 
      else 
        puts "Invalid choice. Please try again."
      end
    end
  end

  private 

  def view_all_receipts 
    puts "\n=== All Receipts ==="
    response = @api_client.get_receipts 

    if response.empty? 
      puts "No receipts found. Try exiting the CLI and running 'bundle exec rake db:seed'."
    else 
      display_receipts(response)
    end

    loop do 
      puts "\n=== Receipt Menu ==="
      puts "1. Filter by store"
      puts "2. See receipt details"
      puts "3. Edit a receipt"
      puts "4. Back to main menu"
      print "Enter your choice: "
      option = gets.chomp.downcase 

      case option 
      when '1'
        filter_receipts_by_store 
      when '2'
        print "Enter receipt ID: "
        id = gets.chomp 
        show_receipt_details(id)
      when '3'
        print "Enter receipt ID: "
        id = gets.chomp 
        show_receipt_details(id)
        edit_receipt_menu(id)
      when '4'
        break 
      else
        puts "Invalid choice. Please try again."
      end
    end
  end

  def display_receipts(receipts)
    receipts.each do |receipt|
      puts "ID: #{receipt['id']}"
      puts "Date: #{receipt['date']}"
      puts "Store: #{receipt['store']['name']}"
      puts "Total: $#{total_price(receipt['items'])}"
      puts "----------"
    end
  end

  def filter_receipts_by_store 
    print "Enter store name (case sensitive): "
    store_name = gets.chomp 

    response = @api_client.get_receipts_by_store(store_name) 

    if response.empty? 
      puts "No receipts found for store '#{store_name}'."
    else 
      puts "\n=== Receipts for Store: #{store_name} ==="
      display_receipts(response) 
    end
  end

  def show_receipt_details(id) 
    receipt = @api_client.get_receipt_by_id(id)
    puts "\n=== Receipt from #{receipt['date']} for Store: #{receipt['store']['name']} ==="
    receipt['items'].each do |item|
      puts "#{item['name']}: $#{item['price']}"
    end
    puts "----------"
    puts "Total: $#{total_price(receipt['items'])}"
  end

  def total_price(items)
    items.sum { |item| item['price'].to_i }
  end

  def view_all_items 
    puts "\n=== All Purchased Items ==="
    response = @api_client.get_items 

    if response.empty? 
      puts "No receipts found. Try exiting the CLI and running 'bundle exec rake db:seed'."
    else 
      display_items(response, include_store: true)
    end

    loop do 
      puts "\n=== Items Menu ==="
      puts "1. Filter by store"
      puts "2. See an item's full receipt"
      puts "3. Back to main menu"
      print "Enter your choice: "
      option = gets.chomp.downcase 

      case option 
      when '1'
        filter_items_by_store
      when '2'
        print "Enter item ID: "
        item_id = gets.chomp 
        receipt_id = @api_client.get_receipt_id_by_item(item_id)
        show_receipt_details(receipt_id)
      when '3'
        break 
      else
        puts "Invalid choice. Please try again."
      end
    end
  end

  def display_items(items, include_store: false)
    items.each do |item| 
      puts "#{item['name']}: $#{item['price']}"
      puts "Bought from: #{item['store']['name']}" if include_store 
      puts "ID: #{item['id']}"
      puts "----------"
    end
    puts "Total: $#{total_price(items)}"
  end

  def filter_items_by_store 
    print "Enter store name (case sensitive): "
    store_name = gets.chomp 

    response = @api_client.get_items_by_store(store_name)

    if response.empty? 
      puts "No purchased items found for store '#{store_name}'."
    else 
      puts "\n=== Items Purchased at Store: #{store_name} ==="
      display_items(response)
    end
  end

  def create_new_receipt 
    puts "\n=== Add a New Receipt ==="
    print "Enter shopping date (YYYY-MM-DD): "
    date = gets.chomp 

    print "Enter store name: "
    store_name = gets.chomp 

    items = []

    loop do 
      print "Enter item name (or press enter to finish): "
      name = gets.chomp 
      break if name.empty? && !items.empty? 

      if name.empty? 
        puts "You must add at least one item."
        next 
      end

      price = nil 
      loop do
        print "Enter price in dollars (round up or down to a whole number): "
        price_input = gets.chomp 
        if price_input.match?(/^\d+$/)
          price = price_input.to_i 
          break 
        else 
          puts "PRICE INVALID: Please enter a whole number (no decimals, letters, or symbols)."
        end
      end
      items << { name: name.capitalize, price: price }
    end

    response = @api_client.create_receipt(date: date, store_name: store_name.capitalize, items: items)

    if response["error"]
      puts "Failed to create receipt: #{response["error"]}"
    else 
      puts "\nReceipt created successfully!"
      show_receipt_details(response["id"])
    end
  end

  def edit_receipt_menu(id)
    loop do 
      puts "\n=== Edit Receipt Menu ==="
      puts "1. Edit date"
      puts "2. Edit store name"
      puts "3. Edit an item"
      puts "4. Add an item"
      puts "5. Delete an item"
      puts "6. Go back to receipts view"
      print "Choose an option: "
      choice = gets.chomp 

      case choice 
      when '1'
        print "Enter new date (YYYY-MM-DD): "
        new_date = gets.chomp 
        response = @api_client.update_receipt_date(id, new_date)

        if response["error"]
          puts "Failed to update receipt: #{response["error"]}"
        else 
          puts "Date updated successfully!"
          show_receipt_details(id)
        end
      when '2'
        print "Enter new store name: "
        new_store = gets.chomp 
        response = @api_client.update_receipt(id, { store_name: new_store })

        if response["error"]
          puts "Failed to update store: #{response["error"]}"
        else 
          puts "Store updated successfully!"
          show_receipt_details(id)
        end
      when '3'
        receipt = @api_client.get_receipt_by_id(id)
        items = receipt["items"]

        puts "\n=== Select an Item to Edit ==="
        items.each_with_index do |item, index| 
          puts "#{index + 1}. #{item['name']} - $#{item['price']}"
        end

        print "Enter the number of the item you'd like to edit: "
        item_index = gets.chomp.to_i - 1

        if item_index < 0 || item_index >= items.length 
          puts "Invalid item selection."
          next
        end

        selected_item = items[item_index]

        print "Enter updated name for '#{selected_item['name']}': "
        new_name = gets.chomp.capitalize 

        new_price = nil 
        loop do 
          print "Enter new price in dollars (round up or down to a whole number): "
          input = gets.chomp 
          if input.match?(/^\d+$/)
            new_price = input.to_i 
            break 
          else 
            puts "PRICE INVALID: Please enter a whole number (no decimals, letters, or symbols)." 
          end
        end

        response = @api_client.update_item(selected_item["id"], {
          name: new_name,
          price: new_price 
        })

        if response["error"]
          puts "Failed to update item: #{response["error"]}"
        else 
          puts "Item updated successfully!"
          show_receipt_details(id)
        end
      when '4'
        receipt = @api_client.get_receipt_by_id(id)
        store_id = receipt["store"]["id"]

        print "Enter item name: "
        item_name = gets.chomp.capitalize

        item_price = nil 
        loop do 
          print "Enter new price in dollars (round up or down to a whole number): "
          input = gets.chomp 
          if input.match?(/^\d+$/)
            item_price = input.to_i 
            break 
          else 
            puts "PRICE INVALID: Please enter a whole number (no decimals, letters, or symbols)." 
          end
        end

        response = @api_client.create_item(
          name: item_name,
          price: item_price,
          receipt_id: id,
          store_id: store_id
        )

        if response["error"]
          puts "Failed to add item: #{response["error"]}"
        else 
          puts "Item added successfully!"
          show_receipt_details(id)
        end
      when '5'
        receipt = @api_client.get_receipt_by_id(id)
        items = receipt["items"]

        if items.empty? 
          puts "There are no items to delete."
          next 
        end

        puts "\n=== Select an Item to Delete ==="
        items.each_with_index do |item, index| 
          puts "#{index + 1}. #{item['name']} - $#{item['price']}"
        end

        print "Enter the number of the item you'd like to delete: "
        item_index = gets.chomp.to_i - 1

        if item_index < 0 || item_index >= items.length 
          puts "Invalid item selection."
          next
        end

        selected_item = items[item_index]
        begin
          @api_client.delete_item(selected_item["id"])
          puts "Item deleted successfully."
          show_receipt_details(id)
        rescue RestClient::ExceptionWithResponse => e 
          error_response = JSON.parse(e.response) rescue nil 
          error_message = error_response && error_response["error"] || e.message
          puts "Failed to delete item: #{response["error"]}" 
        end
      when '6'
        response = @api_client.get_receipts 
        puts "\n=== All Receipts ==="
        display_receipts(response)
        break
      else 
        puts "Invalid option."
      end
    end
  end
end

if __FILE__ == $0 
  CLIInterface.new.run 
end
