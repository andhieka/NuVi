class Module
  
  def initialize(code, mc, prereq, coreq, preclu, cross)
    # Yang ga penting kyk description, department, dll ga masuk dulu
    @code = code
    @level = (code[/\d+/].to_i/1000) * 1000
    @MC = mc
    @prerequisite = prereq
    @corequisite = coreq
    @preclusion = preclu
    @crosslisting = cross
  end

  # Getter methods
  def get_code()
    return @code
  end
  
  def get_level()
    return @level
  end

  def get_MC()
    return @MC
  end

  def get_prerequisite()
    return @prerequisite
  end

  def get_corequisite()
    return @corequisite
  end

  def get_preclusion()
    return @preclusion
  end

  def get_crosslisting()
    return @crosslisting
  end

end