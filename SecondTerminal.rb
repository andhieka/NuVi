require "yaml"
require_relative "Pair.rb"
require_relative "Utility.rb"
require_relative "Module.rb"
require_relative "ModuleTreeNode.rb"
require_relative "ModuleTree.rb"
require_relative "ModuleDatabase.rb"
require_relative "Planner.rb"
require_relative "IntegratedProcessor.rb"

module SecondTerminal
  terminal = IntegratedProcessor.new(Modules)
  nilarg = ["nextsem", "prevsem", "reset", "checksem", "checkmc", "checkplanner", "quit"]
  onearg = ["add", "remove", "forceadd", "gotosem", "clearfromsem", "save", "load"]
  puts "Welcome to NuVi! Type help to get list of available commands."
  puts "Please enter your first command: "
  input = gets.chomp
  words = input.split(" ")
  cmd = words[0]
  while !Utility.input_checker(input, nilarg, onearg) || cmd != "quit" do
    if !Utility.input_checker(input, nilarg, onearg)
      puts "Bad input!"
    else
      case cmd.downcase
      when "add"
        terminal.add_module(words[1])
      when "remove"
        terminal.remove_module(words[1])
      when "forceadd"
        terminal.force_add_module(words[1])
      when "nextsem"
        terminal.go_to_next_sem()
        puts "Planner status: advanced to semester #{terminal.get_semester()}!"
      when "prevsem"
        terminal.go_to_prev_sem()
      when "gotosem"
        terminal.go_to_sem(words[1].to_i)
      when "reset"
        puts "This process cannot be undone. Are you sure you want to proceed? (Yes/No)"
        if Utility.get_yes_no_input()
          terminal = IntegratedProcessor.new(Modules)
          puts "Terminal reset!"
        else
          puts "Process cancelled!"
        end
      when "clearfromsem"
        terminal.clear_planner_from_sem(words[1].to_i)
      when "checksem"
        terminal.check_current_semester()
      when "checkmc"
        terminal.check_MC()
      when "checkplanner"
        terminal.check_planner()
      when "save"
        terminal.save(words[1])
      when "load"
        terminal.load(words[1])
      end
    end
    puts "Enter your next command: "
    input = gets.chomp
    words = input.split(" ")
    cmd = words[0]
  end

  puts "Thank you for using NuVi!"

end