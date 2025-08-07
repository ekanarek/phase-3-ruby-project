module InputHelpers 
  def prompt(message)
    print message 
    gets.chomp 
  end

  def get_valid_integer(message) 
    loop do 
      print message 
      input = gets.chomp 
      return input.to_i if input.match?(/^\d+$/)

      puts "PRICE INVALID: Please enter a whole number." 
    end
  end
end
