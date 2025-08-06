require 'json' 
require 'rest-client' 

class APIClient 
  def initialize(base_url = "http://localhost:9292/")
    @base_url = base_url 
  end

  def get_receipts 
    get_request("receipts")
  end

  def get_receipts_by_store(store) 
    get_request("receipts", { store: store })
  end

  def get_receipt_by_id(id)
    get_request("receipts/#{id}")
  end

  def get_items 
    get_request("items") 
  end

  def get_items_by_store(store)
    get_request("items", { store: store })
  end

  def get_receipt_id_by_item(item_id)
    get_request("items/#{item_id}")['receipt_id']
  end

  def create_receipt(date:, store_name:, items:)
    payload = {
      date: date,
      store_name: store_name,
      items: items 
    }

    response = RestClient.post(@base_url + "receipts", payload.to_json, { content_type: :json, accept: :json} )
    JSON.parse(response.body)
  rescue RestClient::Exception => e 
    { error: "POST /receipts failed: #{e.message}" }
  end

  private 

  def get_request(endpoint, params = nil) 
    url = @base_url + endpoint 
    options = params ? { params: params } : {}

    response = RestClient.get(url, options)
    JSON.parse(response.body)
  rescue RestClient::Exception => e 
    { error: "GET #{endpoint} failed: #{e.message}" }
  end
end
