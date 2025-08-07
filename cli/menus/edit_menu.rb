require_relative '../helpers/display_helpers'
require_relative '../helpers/input_helpers'

class EditMenu 
  include DisplayHelpers 
  include InputHelpers 

  def initialize(api_client, receipts_menu) 
    @api_client = api_client 
    @receipts_menu = receipts_menu 
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
      @receipts_menu.show_receipt_details(id) 
    end
  end

  def edit_receipt_store(id) 
    new_store = prompt("Enter store name: ")
    response = @api_client.update_receipt(id, { store_name: new_store })

    if response["error"] 
      puts "Failed to update store: #{response["error"]}"
    else 
      puts "Store updated successfully!" 
      @receipts_menu.show_receipt_details(id)
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
      @receipts_menu.show_receipt_details(receipt_id)
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
      @receipts_menu.show_receipt_details(receipt_id)
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
      @receipts_menu.show_receipt_details(receipt_id)
    rescue RestClient::ExceptionWithResponse => e 
      error_response = JSON.parse(e.response) rescue nil 
      error_message = error_response && error_response["error"] || e.message
      puts "Failed to delete item: #{response["error"]}" 
    end
  end
end
