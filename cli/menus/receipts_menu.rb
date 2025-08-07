require_relative '../helpers/display_helpers'
require_relative '../helpers/input_helpers'

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
        edit_receipt_menu(id)
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
      when '1' then edit_receipt_date(id)
      when '2' then edit_receipt_store(id) 
      when '3' then edit_item(id)
      when '4' then add_item(id) 
      when '5' then delete_item(id)
      when '6' 
        puts "\n=== All Receipts ==="
        display_receipts(@api_client.get_receipts) 
        break 
      else 
        puts "Invalid option."
      end
    end
  end

  private 

  def edit_receipt_date(id) 
    new_date = prompt("Enter new date (YYYY-MM-DD): ")
    response = @api_client.update_receipt(id, { date: new_date })

    if response["error"]
      puts "Failed to update receipt: #{response["error"]}"
    else 
      puts "Date updated successfully!"
      show_receipt_details(id) 
    end
  end

  def edit_receipt_store(id) 
    new_store = prompt("Enter store name: ")
    response = @api_client.update_receipt(id, { store_name: new_store })

    if response["error"] 
      puts "Failed to update store: #{response["error"]}"
    else 
      puts "Store updated successfully!" 
      show_receipt_details(id)
    end
  end

  def edit_item(receipt_id)
    receipt = @api_client.get_receipt_by_id(receipt_id)
    items = receipt["items"] 

    puts "\n=== Select an Item to Edit ==="
    items.each_with_index { |item, index| puts "#{index + 1}. #{item['name']} - $#{item['price']}" }

    index = get_valid_integer("Enter the number of the item to edit: ") - 1 
    return puts "Invalid item selection." unless items[index] 

    item = items[index]
    new_name = prompt("Enter updated name for '#{item['name']}': ").capitalize 
    new_price = get_valid_integer("Enter new price in dollars: ")

    response = @api_client.update_item(item["id"], { name: new_name, price: new_price })

    if response["error"]
      puts "Failed to update item: #{response["error"]}"
    else 
      puts "Item updated successfully!"
      show_receipt_details(receipt_id)
    end
  end

  def add_item(receipt_id)
    receipt = @api_client.get_receipt_by_id(receipt_id)
    store_id = receipt["store"]["id"]

    item_name = prompt("Enter item name: ").capitalize
    item_price = get_valid_integer("Enter item price in dollars: ")

    response = @api_client.create_item(
      name: item_name,
      price: item_price,
      receipt_id: receipt_id,
      store_id: store_id
    )

    if response["error"]
      puts "Failed to add item: #{response["error"]}"
    else 
      puts "Item added successfully!"
      show_receipt_details(receipt_id)
    end
  end

  def delete_item(receipt_id)
    receipt = @api_client.get_receipt_by_id(receipt_id)
    items = receipt["items"]

    if items.empty? 
      puts "There are no items to delete."
    end

    puts "\n=== Select an Item to Delete ==="
    items.each_with_index { |item, index| puts "#{index + 1}. #{item['name']} - $#{item['price']}" } 

    index = get_valid_integer("Enter the number of the item you'd like to delete: ") - 1
    return puts "Invalid item selection." unless items[index]

    item = items[index]
    begin
      @api_client.delete_item(item["id"])
      puts "Item deleted successfully."
      show_receipt_details(receipt_id)
    rescue RestClient::ExceptionWithResponse => e 
      error_response = JSON.parse(e.response) rescue nil 
      error_message = error_response && error_response["error"] || e.message
      puts "Failed to delete item: #{response["error"]}" 
    end
  end
end
