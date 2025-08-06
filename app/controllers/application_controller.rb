# frozen_string_literal: true

class ApplicationController < Sinatra::Base
  set :default_content_type, "application/json"

  get "/receipts" do
    receipts = Receipt.all

    if params[:store]
      store = Store.find_by(name: params[:store])
      receipts = receipts.where(store_id: store.id) if store 
    end

    receipts.order(date: :desc).to_json(include: [:store, :items])
  end

  get "/receipts/:id" do 
    receipt = Receipt.find(params[:id])
    receipt.to_json(include: [:store, :items])
  rescue ActiveRecord::RecordNotFound 
    status 404 
    { error: "Receipt not found" }.to_json 
  end

  get "/items" do 
    items = Item.all

    if params[:store] 
      store = Store.find_by(name: params[:store])
      items = items.where(store_id: store.id) if store 
    end

    items.to_json(include: [:store, :receipt])
  end

  get "/items/:id" do 
    item = Item.find(params[:id])
    item.to_json 
  rescue ActiveRecord::RecordNotFound 
    status 404 
    { error: "Item not found" }.to_json 
  end

  post "/receipts" do 
    data = JSON.parse(request.body.read) 
    store_name = data["store_name"]
    date = data["date"]
    items = data["items"]

    store = Store.find_or_create_by(name: store_name)
    receipt = Receipt.create(date: date, store: store)

    items.each do |item_data| 
      Item.create(
        name: item_data["name"],
        price: item_data["price"],
        receipt: receipt,
        store: store
      )
    end

    receipt.to_json(include: [:store, :items])
  end

  patch "/receipts/:id" do 
    data = JSON.parse(request.body.read) 
    receipt = Receipt.find(params[:id])

    receipt.update(date: data["date"]) if data["date"]

    if data["store_name"]
      store_name = data["store_name"].capitalize 
      store = Store.find_or_create_by(name: store_name)
      receipt.update(store: store)

      receipt.items.each do |item| 
        item.update(store: store)
      end
    end

    receipt.to_json(include: [:store, :items])
  rescue ActiveRecord::RecordNotFound 
    status 404
    { error: "Receipt not found" }.to_json 
  end

  patch "/items/:id" do 
    data = JSON.parse(request.body.read)
    item = Item.find(params[:id])

    item.update(
      name: data["name"].capitalize, 
      price: data["price"].to_i 
    )

    item.to_json 
  rescue ActiveRecord::RecordNotFound 
    status 404
    { error: "Item not found" }.to_json 
  end
end
