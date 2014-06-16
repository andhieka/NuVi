require_relative "Pair.rb"
require_relative "Utility.rb"
require_relative "Module.rb"
require_relative "ModuleTreeNode.rb"
require_relative "ModuleTree.rb"
require_relative "ModuleDatabase.rb"
require_relative "ProcessorPt1.rb"
require_relative "ProcessorPt2.rb"

module MainTerminal
  state = "first"
  terminal = ProcessorPt1.new(Modules)
  terminus = []
  puts "Welcome to NuVi! Type help to get list of available commands."
  puts "Please enter your first command: "
  input = gets.chomp
  words = input.split(" ")
  cmd = words[0]
  while ((state == "first" && terminal.check_bad_input(input)) || (state == "second" && terminus.check_bad_input(input)) || cmd != "quit") do
    if state == "first"
      if (terminal.check_bad_input(input))
        puts "Bad input!"
      else
        case cmd.downcase
        when "add"
          terminal.add_module(words[1])
        when "remove"
          terminal.remove_module(words[1])
        when "clear"
          terminal.clear()
        when "checkmod"
          terminal.check_modules()
        when "checkmc"
          terminal.check_MC()
        when "proceed"
          state = "second"
          terminus = ProcessorPt2.new(Modules, terminal.get_module_tree().clone(), terminal.get_module_hashtable())
        when "help"
          terminal.show_help()
        end
      end
    else
      if (terminus.check_bad_input(input))
        puts "Bad input!"
      else
        case cmd.downcase
        when "add"
          terminus.add_module(words[1])
        when "remove"
          terminus.remove_module(words[1])
        when "nextsem"
          terminus.go_to_next_sem()
        when "prevsem"
          terminus.go_to_prev_sem()
        when "backtosem"
          terminus.back_to_sem(words[1].to_i)
        when "currsem"
          terminus.check_current_semester()
        when "checkavail"
          terminus.check_available_mods()
        when "printplanner"
          terminus.print_planner()
        when "backtomods"
          state = "first"
        when "help"
          terminus.show_help()
        end
      end
    end
    puts "Enter your next command: "
    input = gets.chomp
    words = input.split(" ")
    cmd = words[0]
  end
  puts "Thanks for using NuVi!"
end