class IntegratedProcessor
  def initialize(mod_data)

    @module_database = mod_data
    @module_hashtable = {}
    @module_tree = ModuleTree.new(@module_hashtable, {})

    @overall_planner = Planner.new([], @module_tree)
    @current_semester_planner = []
    # @add_to_next_sem = []

    @level_1000_MC = 0
    @level_1000_MC_limit = 60

    @current_semester = 1

  end

  def get_semester()
    return @current_semester
  end

  def get_planner()
    return @overall_planner
  end
  
  def get_level_1000()
    return @level_1000_MC
  end

  # Helper functions

  def crosslisted_added(mod)
    cross = @module_database[mod].get_crosslisting()
    cross.each { |m|
      if @overall_planner.check_if_within_sem(m, @overall_planner.get_total_semester()) || @current_semester_planner.include?(m)
        return Pair.new(true, m)
      end
    }
    return Pair.new(false, [])
  end

  def can_add_module(mod)
    if @overall_planner.check_if_within_sem(mod, @overall_planner.get_total_semester()) || @current_semester_planner.include?(mod)
      return Pair.new(false, Pair.new("Module already added!", []))
    elsif !@module_database.has_key?(mod)
      return Pair.new(false, Pair.new("Module not found in database!", []))
    elsif crosslisted_added(mod).get_head()
      return Pair.new(false, Pair.new("You have added another module crosslisted with #{mod}: ", [crosslisted_added(mod).get_tail()]))
    elsif precluded(mod)
      return Pair.new(false, Pair.new("You are precluded from this module because you have taken:", precluded_mods(mod)))
    elsif !prereq_fulfilled(mod)
      return Pair.new(false, Pair.new("You haven't fulfilled the following pre-requisite(s):", prereq_status(mod).get_tail()))
    else
      return Pair.new(true, Pair.new([], []))
    end
  end

  def prereq_status(mod)
    mod = @module_database[mod]
    prereq_fulfilled = []
    prereq_unfulfilled = []
    mod.get_prerequisite().each { |m|
      if (m.is_a? Array)
        indicator = false
        m.each { |mm|
          if (@overall_planner.check_if_within_sem(mm, @current_semester - 1))
            indicator = true
            prereq_fulfilled << mm
            break
          end
        }
        if (!indicator)
          prereq_unfulfilled << m
        end
      elsif @overall_planner.check_if_within_sem(m, @current_semester - 1)
        prereq_fulfilled << m
      elsif !@overall_planner.check_if_within_sem(m, @current_semester - 1)
        prereq_unfulfilled << m
      end
    }
    return Pair.new(prereq_fulfilled, prereq_unfulfilled)
  end

  def prereq_fulfilled(mod)
    return prereq_status(mod).get_tail().empty?
  end

  def precluded_mods(mod)
    ans = []
    mod = @module_database[mod]
    mod.get_preclusion().each { |m|
      if @overall_planner.check_if_within_sem(m, @overall_planner.get_total_semester()) || @current_semester_planner.include?(m)
        ans << m
      end
    }
    return ans
  end

  def precluded(mod)
    return !precluded_mods(mod).empty?
  end

  # Main functions

  def add_module(mod)

    if !can_add_module(mod).get_head()
      puts can_add_module(mod).get_tail().get_head()
      if !can_add_module(mod).get_tail().get_tail().empty?
        Utility.list_down(can_add_module(mod).get_tail().get_tail(), "and")
        puts ""
      end

    else

      temp = [mod]
      to_be_added = []
      sibling_pairs = []
      indicator = true

      while !temp.empty?
        m = temp.shift()
        to_be_added << m
        coreq = @module_database[mod].get_corequisite()
        if !coreq.empty?
          coreq.each { |c|
            stat = c.get_tail()
            cor = c.get_head()
=begin
            if stat == "after"
              puts "Reminder: you need to add #{c} next semester!"
              add_to_next_sem << c
            elsif stat == "before"
              if @overall_planner.check_if_in_sem(mod, @current_semester - 1)
                temp << c
                sibling_pairs << Pair.new(Pair.new(m, c), "before")
              else
                indicator = false
                puts "You cannot add #{mod} as you haven't taken #{c}, its co-requisite!"
                break
              end
=end
            if stat == "same"
              if to_be_added.include?(cor)

              elsif can_add_module(cor).get_head()
                puts "Adding #{m} also requires you to add #{cor}. Proceed? (Yes/No)"
                if Utility.get_yes_no_input
                  temp << cor
                  sibling_pairs << Pair.new(Pair.new(m, cor), "same")
                else
                  indicator = false
                  puts "#{mod} not added!"
                  break
                end
              else
                indicator = false
                puts "You cannot add #{mod} as you cannot add #{cor}, its co-requisite!"
                break
              end
            end
          }
        end
      end

      if indicator
        to_be_added.each { |m|
          if @module_hashtable.has_key?(m)
            node = @module_hashtable[m]
          else
            @module_hashtable[m] = ModuleTreeNode.new(m)
          end
          @current_semester_planner << m
          @module_tree.add_node(m, prereq_status(m).get_head())
          if @module_database[m].get_level() == 1000
            @level_1000_MC += @module_database[m].get_MC()
          end
          puts "#{m} added!"
        }

        if @level_1000_MC > @level_1000_MC_limit
          puts "Warning: Level 1000 MC exceeded normal limit!"
        end

      end

      if !sibling_pairs.empty?
        sibling_pairs.each { |sib|
          first = sib.get_head().get_head()
          second = sib.get_head().get_tail()
          type = sib.get_tail()
          @module_tree.add_sibling(@module_hashtable[first], @module_hashtable[second], type)
        }
      end

    end
  end

  def force_add_module(mod)
    if @overall_planner.check_if_within_sem(mod, @overall_planner.get_total_semester()) || @current_semester_planner.include?(mod)
      puts "Module already added!"
    elsif !@module_database.has_key?(mod)
      puts "Module not found in database!"
    else
      if @module_hashtable.has_key?(mod)
        node = @module_hashtable[mod]
      else
        @module_hashtable[mod] = ModuleTreeNode.new(mod)
      end
      @current_semester_planner << mod
      @module_tree.add_node(mod, [])
      if @module_database[mod].get_level() == 1000
        @level_1000_MC += @module_database[mod].get_MC()
      end
      puts "#{mod} force-added!"
    end
  end

  def remove_module(mod)

    if !@current_semester_planner.include?(mod)
      cross = @module_database[mod].get_crosslisting() & @current_semester_planner
      if cross.empty?
        puts "Module not found in current semester planner!"
      else
        puts "You have not added #{mod}, but you have added #{cross[0]} which is cross-listed with it."
        puts "Proceed to remove #{cross[0]}? (Yes/No)"
        if Utility.get_yes_no_input()
          remove_module(cross[0])
        else
          puts "Process cancelled!"
        end
      end

    else

      temp = [mod]
      to_be_removed = []
      indicator = true

      while !temp.empty? do
        m = temp.shift()
        to_be_removed << m
        sib = @module_hashtable[m].get_sibling().clone()
        sib += @module_hashtable[m].get_parent().clone()
        sib.each { |mm|
          if !to_be_removed.include?(mm)
            temp << mm
          end
        }
      end

      if to_be_removed.length > 1
        m = to_be_removed.shift()
        print "Removing #{m} also requires you to remove "
        Utility.list_down(to_be_removed, "and")
        puts ""
        to_be_removed.unshift(m)
        puts "Are you sure you want to remove #{mod}? (Yes/No)"
        if !Utility.get_yes_no_input()
          indicator = false
        end
      end

      if indicator
        to_be_removed.each { |m|
          @current_semester_planner -= [m]
          @overall_planner.remove_mod(m)
          if @module_database[m].get_level() == 1000
            @level_1000_MC -= @module_database[m].get_MC()
          end
          @module_tree.remove_node(m)
        }
        Utility.list_down(to_be_removed, "and")
        puts " cleared!"
      end

    end

  end

  def go_to_next_sem()
    @overall_planner.add_plan_to_sem(@current_semester_planner.clone(), @current_semester)
    @current_semester += 1
    if @overall_planner.get_planner().length < @current_semester
      @current_semester_planner = []
    else
      @current_semester_planner = @overall_planner.get_plan_for_sem(@current_semester)
    end
=begin
    if !@add_to_next_sem.empty?
      add = @add_to_next_sem.clone()
      @add_to_next_sem.each { |mod|
        add_module(mod)
      }
      @add_to_next_sem = []
      list_down(add, "and")
      puts " automatically added to semester #{@current_semester} planner!"
    end
=end
  end

  def go_to_prev_sem()
    if @current_semester == 1
      puts "Error: this is still first semester!"
    else
      go_to_next_sem()
      @current_semester -= 2
      @current_semester_planner = @overall_planner.get_plan_for_sem(@current_semester)
      puts "Planner status: back to semester #{@current_semester}!"
    end
  end

  def go_to_sem(sem)
    if sem == @current_semester
      puts "You are currently in semester #{sem}!"
    elsif sem > @overall_planner.get_planner().length
      puts "You haven't reached semester #{sem} yet!"
    else
      go_to_next_sem()
      @current_semester = sem
      @current_semester_planner = @overall_planner.get_plan_for_sem(@current_semester)
      puts "Planner status: moved to semester #{sem}!"
    end
  end

  def clear_planner_from_sem(sem)
    if sem == 1
      puts "Please use the reset command!"
    elsif sem < 1 || sem > [@overall_planner.get_planner().length, @current_semester].max
      puts "Error: unacceptable input!"
    else
      puts "This process cannot be undone. Are you sure you want to proceed? (Yes/No)"
      if Utility.get_yes_no_input()
        go_to_next_sem()
        plan = @overall_planner.get_planner()
        last_sem = plan.length
        while (last_sem >= sem)
          go_to_sem(last_sem)
          plan[last_sem - 1].each { |mod|
            remove_module(mod)
          }
          plan.pop()
          last_sem -= 1
        end
      else
        puts "Process cancelled!"
      end
    end
  end

  def check_current_semester()
    if @current_semester_planner.empty?
      puts "Nothing added yet for this semester!"
    else
      total = 0
      @current_semester_planner.each { |mod|
        total += @module_database[mod].get_MC()
      }
      print "Modules taken this semester: "
      Utility.list_down(@current_semester_planner, "and")
      puts", total #{total} MCs"
    end
  end

  def check_MC()
    total = 0
    level1000 = 0
    plan = @overall_planner.get_planner()
    if !plan.empty?
      for i in 1..plan.length
        if i != @current_semester
          plan[i-1].each { |mod|
            total += @module_database[mod].get_MC()
            if @module_database[mod].get_level() == 1000
              level1000 += @module_database[mod].get_MC()
            end
          }
        else
          @current_semester_planner.each { |mod|
            total += @module_database[mod].get_MC()
            if @module_database[mod].get_level() == 1000
              level1000 += @module_database[mod].get_MC()
            end
          }
        end
      end
    end
    if @current_semester > plan.length
      @current_semester_planner.each { |mod|
        total += @module_database[mod].get_MC()
        if @module_database[mod].get_level() == 1000
          level1000 += @module_database[mod].get_MC()
        end
      }
    end
    puts "Total MCs fulfilled: #{total} MCs"
    puts "Total Level 1000 MCs: #{level1000} MCs"
  end

  def check_planner()
    plan = @overall_planner.get_planner()
    if !plan.empty?
      for i in 1..plan.length
        print "Semester #{i}: "
        if i != @current_semester
          Utility.list_down(plan[i-1], "and")
        else
          Utility.list_down(@current_semester_planner, "and")
        end
        puts ""
      end
    end
    if @current_semester > plan.length
      print "Semester #{@current_semester}: "
      Utility.list_down(@current_semester_planner, "and")
      puts ""
    end

  end

  def save(filename)
    go_to_next_sem()
    go_to_prev_sem()
    filename << ".nuvi"
    File.open(filename, 'w') { |file|
      file.write(YAML.dump(self))
    }
    puts "Planner saved as #{filename}!"
  end

  def load(filename)
    filename << ".nuvi"
    another = YAML.load(File.read(filename))
    @overall_planner = another.get_planner()
    @module_tree = @overall_planner.get_tree()
    @module_hashtable = @module_tree.get_hashtable()
    @level_1000_MC = another.get_level_1000()
    @current_semester = another.get_semester()
    @current_semester_planner = @overall_planner.get_plan_for_sem(@current_semester)
    puts "#{filename} loaded!"
  end

=begin

  # basic functions
  add module ONGOING
  remove module ONGOING
  forceadd module DONE

  # navigators
  nextsem DONE
  prevsem DONE
  gotosem sem DONE

  # clearers
  reset DONE
  clearfromsem sem DONE

  # utility functions
  checksem DONE
  checkmc DONE
  checkplanner DONE

  # save/load functions
  save filename DONE
  load filename DONE

  # mandatory functions
  help (ditunggu sampe semua functions ada)
  quit DONE

=end

end