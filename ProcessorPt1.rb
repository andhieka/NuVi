
class ProcessorPt1
  def initialize(mod_data)
    @module_database = mod_data
    @module_hashtable = {}
    @module_tree = ModuleTree.new(@module_hashtable, [])
    @module_taken = []
    @MC_completed = 0
  end

  # Getter methods

  def get_module_database()
    return @module_database
  end

  def get_module_hashtable()
    return @module_hashtable
  end

  def get_module_tree()
    return @module_tree
  end

  def get_module_taken()
    return @module_taken
  end

  def get_MC()
    return @MC_completed
  end

  # Prereq-related helper functions

  def prereq_status(mod)
    mod = @module_database[mod]
    prereq_fulfilled = []
    prereq_unfulfilled = []
    mod.get_prerequisite().each { |m|
      if (m.is_a? Array)
        indicator = false
        m.each { |mm|
          if (@module_taken.include?(mm))
            indicator = true
            prereq_fulfilled << mm
            break
          end
        }
        if (!indicator)
          prereq_unfulfilled << m
        end
      elsif @module_taken.include?(m)
        prereq_fulfilled << m
      elsif !(@module_taken.include?(m))
        prereq_unfulfilled << m
      end
    }
    return Pair.new(prereq_fulfilled, prereq_unfulfilled)
  end

  def prereq_fulfilled(mod)
    return prereq_status(mod).get_tail().empty?
  end

  # Preclusion-related helper functions

  def precluded_mods(mod)
    ans = []
    mod = @module_database[mod]
    mod.get_preclusion().each { |m|
      if (@module_taken.include?(m))
        ans << m
      end
    }
    return ans
  end

  def precluded(mod)
    return !precluded_mods(mod).empty?
  end

  # Input checker. Still needs some more improvement.

  def check_bad_input(input)
    words = input.split(" ")
    cmd = words[0]
    case cmd.downcase
    when "add", "remove"
      return words.length != 2
    when "clear", "checkmod", "checkmc", "proceed", "help", "quit"
      return words.length != 1
    else
      return true
    end
  end

  # Main functions

  def can_add_module(mod)
    if @module_taken.include?(mod)
      return Pair.new(false, Pair.new("Module already added", []))
    elsif !@module_database.has_key?(mod)
      return Pair.new(false, Pair.new("Module not found in database!", []))
    elsif precluded(mod)
      return Pair.new(false, Pair.new("You are precluded from this module because you have taken:", precluded_mods(mod)))
    elsif !prereq_fulfilled(mod)
      return Pair.new(false, Pair.new("You haven't fulfilled the following pre-requisite(s):", prereq_status(mod).get_tail()))
    else
      return Pair.new(true, Pair.new([], []))
    end
  end

  def add_module(mod)
    if !can_add_module(mod).get_head()
      puts can_add_module(mod).get_tail().get_head()
      if !can_add_module(mod).get_tail().get_tail().empty?
        Utility.list_down(can_add_module(mod).get_tail().get_tail(), "and")
        puts ""
      end
    else
      to_be_added = [mod]
      indicator = true
      coreq = @module_database[mod].get_corequisite()
      if !coreq.empty?
        coreq = coreq[0].get_head()
        if !can_add_module(coreq).get_head()
          puts "You cannot add #{mod} as you cannot add #{coreq}, its co-requisite!"
          indicator = false
        else
          if !@module_taken.include?(coreq)
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
          if @module_hashtable.has_key?(m)
            node = @module_hashtable[m]
          else
            @module_hashtable[m] = ModuleTreeNode.new(m)
          end
          @module_taken << m
          @module_tree.add_node(m, prereq_status(m).get_head())
          @MC_completed += @module_database[m].get_MC()
          puts "#{m} added!"
        }
        if to_be_added.length > 1
          for i in 1..to_be_added.length-1
            for j in i+1..to_be_added.length
              @module_tree.add_sibling(@module_hashtable[to_be_added[i-1]], @module_hashtable[to_be_added[j-1]])
            end
          end
        end
      end

    end
  end

  def remove_module(mod)
    if !(@module_taken.include?(mod))
      puts "You haven't added the module!"
    else
      indicator = true
      temp = [mod]
      toremove = []

      while !(temp.empty?) do
        m = temp.shift()
        cor = @module_database[m].get_corequisite()
        while !cor.empty? do
          n = cor.pop().get_head()
          if !toremove.include?(n)
            temp << n
          end
        end
        toremove << m
        temp += @module_hashtable[m].get_parent()
      end

      if (toremove.length > 1)
        m = toremove.shift()
        print "Removing #{m} also requires you to remove "
        Utility.list_down(toremove, "and")
        puts ""
        toremove.unshift(m)
        puts "Are you sure you want to remove #{mod}? (Yes/No)"
        if !Utility.get_yes_no_input()
          indicator = false
        end
      end
      if (indicator)
        toremove.each { |m|
          @module_taken -= [m]
          @MC_completed -= @module_database[m].get_MC()
          @module_tree.remove_node(m)
        }
        Utility.list_down(toremove, "and")
        puts " cleared!"
      end
    end
  end

  def clear()
    @module_hashtable = {}
    @module_tree = ModuleTree.new(@module_hashtable)
    @module_taken = []
    @MC_completed = 0
    puts "Data cleared!"
  end

  def check_MC()
    puts "#{@MC_completed} MCs completed!"
  end

  def check_modules()
    if @module_taken.empty?
      puts "No module added!"
    else
      puts "Modules added: "
      @module_taken.each { |mod|
        puts "#{mod}: #{@module_database[mod].get_MC()} MCs"
      }
    end
  end

  def show_help()
    puts "Welcome to NuVi!"
    puts "Here are the list of available commands: "
    puts "add [module] adds a module to the list!"
    puts "remove [module] removes a module from the list!"
    puts "checkmc checks the number of MCs fulfilled!"
    puts "checkmod lists all the modules added!"
    puts "help lists all available commands!"
    puts "quit gets you out of here!"
    puts "Thanks for using NuVi!"
  end

end