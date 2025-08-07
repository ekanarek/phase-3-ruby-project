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
    post_request("receipts", { date: date, store_name: store_name, items: items})
  end

  def create_item(name:, price:, receipt_id:, store_id:)
    post_request("items", { name: name, price: price, receipt_id: receipt_id, store_id: store_id })
  end

  def update_receipt(id, updates)
    patch_request("receipts/#{id}", updates)
  end

  def update_item(id, updates)
    patch_request("items/#{id}", updates)
  end

  def delete_receipt(id)
    delete_request("items/#{id}")
  end

  def delete_item(id)
    delete_request("items/#{id}")
  end

  private 

  def get_request(endpoint, params = nil) 
    url = build_url(endpoint)
    options = params ? { params: params } : {}

    response = RestClient.get(url, options)
    parse_response(response)
  rescue RestClient::Exception => e 
    handle_error("GET", endpoint, e)
  end

  def post_request(endpoint, payload)
    response = RestClient.post(
      build_url(endpoint), 
      payload.to_json, 
      default_headers 
    )
    parse_response(response)
  rescue RestClient::Exception => e 
    handle_error("POST", endpoint, e)
  end

  def patch_request(endpoint, payload)
    response = RestClient.patch(
      build_url(endpoint),
      payload.to_json,
      default_headers
    )
    parse_response(response)
  rescue RestClient::Exception => e 
    handle_error("PATCH", endpoint, e)
  end

  def delete_request(endpoint)
    RestClient.delete(build_url(endpoint))
    true 
  rescue RestClient::Exception => e 
    handle_error("DELETE", endpoint, e)
  end

  def build_url(endpoint)
    "#{@base_url}#{endpoint}"
  end 

  def default_headers 
    { content_type: :json, accept: :json }
  end

  def parse_response(response)
    JSON.parse(response.body)
  end

  def handle_error(method, endpoint, exception)
    { error: "#{method} /#{endpoint} failed: #{exception.message}" }
  end
end
