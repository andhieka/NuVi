class Utility
  
  def self.get_yes_no_input()
    input = gets.chomp
    input.downcase!
    while (input != "yes" && input != "no")
      puts "Unacceptable input. Please enter again: "
      input = gets.chomp
      input.downcase!
    end
    return input == "yes"
  end

  def self.list_it(arg)
    if arg.is_a? Array
      print "("
      list_down(arg, "or")
      print ")"
    else
      print arg
    end
  end

  def self.list_down(list, finalword)
    if list.empty?
      list_it("")
    elsif list.length == 1
      list_it(list[0])
    elsif list.length == 2
      list_it(list[0])
      print " #{finalword} "
      list_it(list[1])
    else
      for i in 0..list.length - 3
        print "#{list_it(list[i])}, "
      end
      list_it(list[list.length-2])
      print " #{finalword} "
      list_it(list[list.length-1])
    end
  end

end