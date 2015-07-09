module IsValidThickness
  def self.call(thickness)
    thickness.to_s == thickness.to_i.to_s
  end
end
