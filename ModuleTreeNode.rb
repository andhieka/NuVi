class ModuleTreeNode
  def initialize(code)
    @code = code
    @child = []
    @parent = []
    @sibling = []
  end

  # Setter methods

  def set_child(chi)
    @child = chi
  end

  def set_parent(par)
    @parent = par
  end

  def set_sibling(sib)
    @sibling = sib
  end

  # Getter methods

  def get_code()
    return @code
  end

  def get_child()
    return @child
  end

  def get_parent()
    return @parent
  end

  def get_sibling()
    return @sibling
  end

  # Updater methods

  def add_child(mod)
    if (mod.is_a? Array)
      @child += mod
    else
      @child << mod
    end
  end

  def remove_child(mod)
    if (mod.is_a? Array)
      @child -= mod
    else
      @child -= [mod]
    end
  end

  def add_parent(mod)
    if (mod.is_a? Array)
      @parent += mod
    else
      @parent << mod
    end
  end

  def remove_parent(mod)
    if (mod.is_a? Array)
      @parent -= mod
    else
      @parent -= [mod]
    end
  end

  def add_sibling(mod)
    if (mod.is_a? Array)
      @sibling += mod
    else
      @sibling << mod
    end
  end

  def remove_sibling(mod)
    if (mod.is_a? Array)
      sibling -= mod
    else
      sibling -= [mod]
    end
  end

  # Emptier methods

  def empty_child()
    @child = []
  end

  def empty_parent()
    @parent = []
  end

  def empty_sibling()
    @sibling = []
  end

end