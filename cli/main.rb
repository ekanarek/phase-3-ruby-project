#!/usr/bin/env ruby

require 'rest-client' 
require 'json' 
require_relative './api_client'
require_relative './menus/receipts_menu'
require_relative './menus/items_menu'

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
      when '1' then ReceiptsMenu.new(@api_client).view_all_receipts
      when '2' then ItemsMenu.new(@api_client).view_all_items 
      when '3' then ReceiptsMenu.new(@api_client).create_new_receipt
      when 'q', 'quit', 'exit' 
        puts "Bye!" 
        break 
      else puts "Invalid choice. Please try again."
      end
    end
  end
end

if __FILE__ == $0 
  CLIInterface.new.run 
end
