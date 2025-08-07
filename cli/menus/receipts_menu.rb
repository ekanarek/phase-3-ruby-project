require_relative '../helpers/display_helpers'
require_relative '../helpers/input_helpers'
require_relative './edit_menu'

class ReceiptsMenu 
  include DisplayHelpers 
  include InputHelpers 

  def initialize(api_client)
    @api_client = api_client 
  end 

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
      puts "4. Delete a receipt"
      puts "5. Back to main menu"
      print "Enter your choice: "
      option = gets.chomp.downcase 

      case option 
      when '1' then filter_receipts_by_store 
      when '2' then show_receipt_details(prompt("Enter receipt ID: "))
      when '3'
        id = prompt("Enter receipt ID: ")
        show_receipt_details(id)
        EditMenu.new(@api_client, self).edit_receipt_menu(id)
      when '4'
        id = prompt("Enter receipt ID: ")
        if @api_client.delete_receipt(id) 
          puts "Receipt deleted successfully!"
        end 
      when '5' then break
      else puts "Invalid choice. Please try again."
      end
    end
  end

  def filter_receipts_by_store 
    store_name = prompt("Enter store name (case sensitive): ") 
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

  def create_new_receipt 
    puts "\n=== Add a New Receipt ==="
    date = prompt("Enter shopping date (YYYY-MM-DD): ")
    store_name = prompt("Enter store name: ")

    items = []

    loop do 
      name = prompt("Enter item name (or press enter to finish): ")
      break if name.empty? && !items.empty? 

      if name.empty? 
        puts "You must add at least one item."
        next 
      end

      price = get_valid_integer("Enter price in dollars (round up or down to a whole number): ")
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
