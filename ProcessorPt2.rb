class ProcessorPt2
  def initialize(mods, tree, hash)
    @module_database = mods
    @module_hashtable = hash

    @module_tree_states = [tree]
    @last_tree = tree.clone()
    @current_tree = tree.clone()

    @avail_mods_states = [tree.get_leaves().clone()]
    @last_avail_mods = tree.get_leaves().clone()
    @current_avail_mods = tree.get_leaves().clone()

    @overall_planner = []
    @current_semester_planner = []

    @MC_sembysem = []
    @total_MC_semester = 0
    @current_semester = 1
  end

  def check_bad_input(input)
    words = input.split(" ")
    cmd = words[0]
    case cmd.downcase
    when "add", "remove", "backtosem"
      return words.length != 2
    when "checkavail", "currsem", "nextsem", "prevsem", "printplanner", "backtomods", "help", "quit"
      return words.length != 1
    else
      return true
    end
  end

  def show_help()
    puts "Welcome to NuVi!"
    puts "Here are the list of available commands: "
    puts "add [module] adds a module to the list!"
    puts "remove [module] removes a module from the list!"
    puts "nextsem finishes the planning for current semester and goes to the next one!"
    puts "prevsem goes back to the planning for the previous semester!"
    puts "backtosem [semester] goes back to the semester of your choice!"
    puts "backtomods goes back to module selection tool!"
    puts "checkavail lists down modules available for adding!"
    puts "currsem lists down modules added for this semester!"
    puts "printplanner prints your study plan up to, but not including, current semester!"
    puts "help lists all available commands!"
    puts "quit gets you out of here!"
    puts "Thanks for using NuVi!"
  end

  def add_module(mod)
    if !@current_avail_mods.include?(mod)
      puts "Module not available for selection!"
    else
      indicator = true
      to_be_added = [mod]
      coreq = @module_hashtable[mod].get_sibling()
      if !coreq.empty?
        coreq = coreq[0]
        if !@current_avail_mods.include?(coreq)
          puts "You cannot add this module as you cannot take #{coreq}, its co-requisite!"
          indicator = false
        else
          if !@current_semester_planner.include?(coreq)
            to_be_added << coreq
            puts "You are also required to add #{coreq}. Proceed? (Yes/No)"
            if !Utility.get_yes_no_input()
              indicator = false
            end
          end
        end
      end

      if (indicator)
        to_be_added.each { |m|
          @current_tree.remove_and_upgrade(m)
          @current_avail_mods  -= [m]
          @current_semester_planner << m
          @total_MC_semester += @module_database[m].get_MC()
          puts "#{m} added to semester #{@current_semester} planner!"
        }
      end
    end
  end

  def remove_module(mod)
    if !@current_semester_planner.include?(mod)
      puts "Module is not in this semester's planner!"
    else
      indicator = true
      to_remove = [mod]

      if !@module_database[mod].get_corequisite().empty?
        to_remove << @module_database[mod].get_corequisite()[0].get_head()
      end

      if (to_remove.length > 1)
        m = to_remove.shift()
        print "Removing #{m} also requires you to remove "
        Utility.list_down(to_remove, "and")
        puts ""
        toremove.unshift(m)
        puts "Are you sure you want to remove #{mod}? (Yes/No)"
        if (!Utility.get_yes_no_input())
          indicator = false
        end
      end
      if (indicator)
        to_remove.each{ |m|
          @current_tree.add_and_downgrade(m, @last_tree)
          @current_avail_mods << m
          @current_semester_planner -= [m]
          @total_MC_semester -= @module_database[m].get_MC()
          puts "#{m} removed from semester #{@current_semester} planner!"
        }
      end
    end
  end

  def go_to_next_sem()

    @module_tree_states << @current_tree.clone()
    @last_tree = @current_tree.clone()

    @avail_mods_states << @current_avail_mods.clone()
    @last_avail_mods = @current_avail_mods.clone()
    @current_avail_mods = @current_tree.get_leaves().clone()

    @overall_planner << @current_semester_planner.clone()
    @current_semester_planner = []

    @MC_sembysem << @total_MC_semester
    @total_MC_semester = 0
    @current_semester += 1
    puts "Planner status: advanced to semester #{@current_semester}"

  end

  def go_to_prev_sem()

    if @current_semester == 1
      puts "You are in the first semester planner! Cannot go backwards!"
    else
      @current_tree = @module_tree_states.pop()
      @last_tree = @module_tree_states[@module_tree_states.length - 1]

      @current_avail_mods = @avail_mods_states.pop()
      @last_avail_mods = @avail_mods_states[@avail_mods_states.length - 1]

      @current_semester_planner = @overall_planner.pop()

      @total_MC_semester = @MC_sembysem.pop()

      @current_semester -= 1
      puts "Planner status: back to semester #{@current_semester}"
    end

  end

  def check_current_semester()
    if @current_semester_planner.empty?
      puts "Nothing added in current semester planner!"
    else
      print "You have added "
      Utility.list_down(@current_semester_planner, "and")
      puts ", total #{@total_MC_semester} MCs."
    end
  end

  def check_available_mods()
    if @current_avail_mods.empty?
      puts "There are no more modules that can be added!"
    else
      print "These modules are available for adding: "
      Utility.list_down(@current_avail_mods, "and")
      puts "."
    end
  end

  def print_planner()
    if (@overall_planner.empty?)
      puts "Nothing in the planner yet!"
    else
      for i in 1..@overall_planner.length
        print ("Semester #{i}: ")
        Utility.list_down(@overall_planner[i-1], "and")
        puts ", total #{@MC_sembysem[i-1]} MCs."
      end
    end
  end

  def back_to_sem(sem)
    if sem > @current_semester
      puts "We are still in semester #{sem}!"
    elsif sem == @current_semester
      puts "We are in semester #{sem}!"
    else
      while (@current_semester > sem) do
        go_to_prev_sem()
        # Mungkin bisa diakalin biar ga perlu tiap semester ditulis
      end
    end
  end

end