class ItemViewPresenter < Presenter
  def status
    if IssuesForItemQuery.call(barcode: barcode).count >= 1
      super + " (on issue list)"
    else
      super
    end
  end

  def location
    case @object.status
    when "stocked"
      @object.tray.barcode
    when "unstocked"
      if @object.bin
        @object.bin.barcode
      else
        "Staging"
      end
    when "shipped"
      "Shipped - Not In Annex"
    end
  end
end
