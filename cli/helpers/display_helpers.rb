module DisplayHelpers 
  def display_receipts(receipts)
    receipts.each do |receipt|
      puts "ID: #{receipt['id']}"
      puts "Date: #{receipt['date']}"
      puts "Store: #{receipt['store']['name']}"
      puts "Total: $#{total_price(receipt['items'])}"
      puts "----------"
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

  def total_price(items)
    items.sum { |item| item['price'].to_i }
  end
end
