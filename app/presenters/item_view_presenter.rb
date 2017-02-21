class ItemViewPresenter < Presenter
  def status
    if IssuesForItemQuery.call(barcode: barcode).where(resolver_id: nil).count >= 1
      super + " (on issue list)"
    else
      super
    end
  end
end
