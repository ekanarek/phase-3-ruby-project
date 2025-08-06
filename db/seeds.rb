# frozen_string_literal: true

puts "🛍️ Seeding..."

# Clear existing data
Store.destroy_all 
Receipt.destroy_all 
Item.destroy_all 

store_names = ["Vans", "The Home Depot", "Sephora", "Bath & Body Works", "Costco"]

# Make 5 stores
store_names.each do |name|
  store = Store.create(name: name)

  # Make 1-5 receipts for each store
  rand(1..5).times do 
    receipt = Receipt.create(
      date: Faker::Date.between(from: "2025-01-01", to: "2025-08-05"),
      store_id: store.id 
    )

    # Add 1-5 items to each receipt 
    rand(1..5).times do 
      Item.create(
        name: Faker::Commerce.product_name,
        price: rand(1..100),
        receipt_id: receipt.id, 
        store_id: store.id 
      )
    end
  end
end

puts "✅ Done seeding!"
