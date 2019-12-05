module IsValidItem
  def self.call(barcode)
    # This is a terrible way to do this.
    parameter_file = File.join(Rails.root, "config", "barcode_patterns.yml")
    settings = YAML.safe_load(File.open(parameter_file), aliases: true)
    parameters = settings["common"]["parameters"]

    #  If there is no regular expression set, the system will skip validation.
    if parameters.count == 0
      return true
    end

    # If there is more than one regular expression set, the barcode is valid if it matches any one of them.
    # And what if you need to fulfill multiple requirements? Terrible.
    parameters.each do |parameter|
      if parameter["enabled"]
        if /^#{parameter["regex"]}(.*)/.match?(barcode)
          return true
        end
      end
    end

    false
  end
end
