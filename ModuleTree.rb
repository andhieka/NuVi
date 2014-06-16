class ModuleTree
  def initialize(hash, leaf)
    @module_hashtable = hash
    @leaves = leaf
  end

  # Getter methods

  def get_hashtable()
    return @module_hashtable
  end

  def get_leaves()
    return @leaves
  end

  # Deep-cloner method. VERY IMPORTANT.
  
  def clone()
    return ModuleTree.new(self.get_hashtable(), self.get_leaves())
  end

  # For Processor Pt 1

  def add_node(node, children)
    if children.empty?
      @leaves << node
    else
      @module_hashtable[node].set_child(children)
      children.each { |chi|
        @module_hashtable[chi].add_parent(node)
      }
    end
  end

  def remove_node(node)
    if @leaves.include?(node)
      @leaves -= [node]
    end
    if !@module_hashtable[node].get_child().empty?
      @module_hashtable[node].get_child().each { |chi|
        @module_hashtable[chi].remove_parent(node)
      }
    end
    @module_hashtable[node].empty_child()
    @module_hashtable[node].empty_parent()
    @module_hashtable[node].empty_sibling()
  end
  
  def add_sibling(node1, node2)
    node1.add_sibling(node2.get_code())
    node2.add_sibling(node1.get_code())
  end

  # For Processor Pt 2

  def remove_and_upgrade(node)
    if !@leaves.include?(node)
      puts "Error!"
    else
      parents = @module_hashtable[node].get_parent()
      @leaves += parents
      remove_node(node)
    end
  end

  def add_and_downgrade(node, last_tree)
    if @leaves.include?(node)
      puts "Error!"
    else
      hash = last_tree.get_hashtable()
      parents = hash[node].get_parent()
      @leaves -= parents
      add_node(node, [])
    end
  end

end