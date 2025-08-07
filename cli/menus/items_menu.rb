require_relative '../helpers/display_helpers'
require_relative '../helpers/input_helpers'
require_relative './receipts_menu'

class ItemsMenu 
  include DisplayHelpers 
  include InputHelpers 

  def initialize(api_client)
    @api_client = api_client 
  end 

  def view_all_items 
    puts "\n=== All Purchased Items ==="
    response = @api_client.get_items 

    if response.empty? 
      puts "No items found. Try exiting the CLI and running 'bundle exec rake db:seed'."
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
      when '1' then filter_items_by_store
      when '2' then show_receipt_for_item
      when '3' then break 
      else puts "Invalid choice. Please try again."
      end
    end
  end

  def filter_items_by_store 
    store_name = prompt("Enter store name (case sensitive): ")
    response = @api_client.get_items_by_store(store_name)

    if response.empty? 
      puts "No purchased items found for store '#{store_name}'."
    else 
      puts "\n=== Items Purchased at Store: #{store_name} ==="
      display_items(response)
    end
  end

  def show_receipt_for_item 
    item_id = prompt("Enter item IDL: ")
    receipt_id = @api_client.get_receipt_id_by_item(item_id)

    if receipt_id 
      ReceiptsMenu.new(@api_client).show_receipt_details(receipt_id)
    else 
      puts "No receipt found for item ID: #{item_id}"
    end
  end
end
