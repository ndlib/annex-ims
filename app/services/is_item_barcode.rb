class IsItemBarcode
  def self.call(barcode)
    return false unless barcode.present?
    return false if IsTrayBarcode.call(barcode)
    return false if IsShelfBarcode.call(barcode)
    return false if IsBinBarcode.call(barcode)
    return false unless new.check_parameters(barcode)
    true
  end

  def check_parameters(barcode)
    parameter_file = File.join(Rails.root, 'config', 'parameters.yml')
    settings = YAML.load(File.open(parameter_file))
    parameters = settings['common']['parameters']

    parameters.each do |parameter|
      if parameter['enabled']
        unless barcode =~ /^#{parameter['regex']}(.*)/
          return false
        end
      end
    end

    return true
  end
end
