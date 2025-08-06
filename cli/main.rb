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
      puts "a. Filter by store"
      puts "b. See receipt details"
      puts "c. Back to main menu"
      print "Enter your choice: "
      option = gets.chomp.downcase 

      case option 
      when 'a'
        filter_receipts_by_store 
      when 'b'
        print "Enter receipt ID: "
        id = gets.chomp 
        show_receipt_details(id)
      when 'c'
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
      puts "a. Filter by store"
      puts "b. See an item's full receipt"
      puts "c. Back to main menu"
      print "Enter your choice: "
      option = gets.chomp.downcase 

      case option 
      when 'a'
        filter_items_by_store
      when 'b'
        print "Enter item ID: "
        item_id = gets.chomp 
        receipt_id = @api_client.get_receipt_id_by_item(item_id)
        show_receipt_details(receipt_id)
      when 'c'
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
end

if __FILE__ == $0 
  CLIInterface.new.run 
end
