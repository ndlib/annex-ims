module IsValidItem
  def self.call(barcode)
    parameter_file = File.join(Rails.root, 'config', 'parameters.yml')
    settings = YAML.load(File.open(parameter_file))
    parameters = settings['common']['parameters']

    #  If there is no regular expression set, the system will skip validation.
    if parameters.count == 0
      return true
    end

    # If there is more than one regular expression set, the barcode is valid if it matches any one of them.
    parameters.each do |parameter|
      if parameter['enabled']
        if barcode =~ /^#{parameter['regex']}(.*)/
          return true
        end
      end
    end

    return false
  end
end
