class IsValidThickness
  attr_reader :thickness

  def self.call(thickness)
    new(thickness).compare
  end

  def initialize(thickness)
    @thickness = thickness
  end

  def compare
    thickness.to_s == thickness.to_i.to_s
  end

end
