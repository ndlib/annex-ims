class BarcodeSpaceValidator < ActiveModel::Validator
  def validate(record)
    if record.barcode.present? && record.barcode.match(/\s/)
      record.errors.add(
        :barcode, I18n.t("errors.barcode_has_spaces", barcode: record.barcode)
      )
    end
  end
end
