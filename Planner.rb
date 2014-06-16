require_relative "Pair.rb"
class Planner
  def initialize(planner, tree)
    @planner = planner
    @tree = tree
  end

  def get_planner()
    return @planner
  end
  
  def get_tree()
    return @tree
  end

  def get_total_semester()
    return @planner.length
  end
  
  def get_plan_for_sem(sem)
    return @planner[sem-1]
  end
  
  def clone()
    return Planner.new(self.get_planner(), self.get_tree())
  end

  def add_plan_to_sem(plan, sem)
    if !plan.is_a? Array
      puts "Error: unacceptable input"
    else
      @planner[sem-1] = plan
    end
  end

  def replace_sem_with(plan, sem)
    if !plan.is_a? Array
      puts "Error: unacceptable input"
    elsif @planner.length < sem
      puts "Error: plan for semester #{sem} not included yet!"
    else
      @planner << plan
    end
  end
  
  def remove_mod(mod)
    for i in 1..@planner.length
      if @planner[i-1].include?(mod)
        @planner[i-1] -= [mod]
      end
    end
  end

  def check_mod_status(mod, sem_limit)
    if @planner.empty?
      return Pair.new(false, 0)
    elsif sem_limit < 1
      return Pair.new(false, 0)
    else
      for i in 1..[sem_limit, @planner.length].min
        if @planner[i-1].include?(mod)
          return Pair.new(true, i)
        end
      end
      return Pair.new(false, 0)
    end
  end

  def check_if_within_sem(mod, sem_limit)
    status = check_mod_status(mod, sem_limit)
    return status.get_head() && status.get_tail() <= sem_limit
  end

  def check_if_in_sem(mod, sem)
    status = check_mod_status(mod, sem)
    return status.get_head() && status.get_tail() == sem
  end

end