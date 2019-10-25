class ItemsController < ApplicationController
  def index
    @item = Item.new
  end

  def scan
    begin
      @item = GetItemFromBarcode.call(barcode: params[:item][:barcode], user_id: current_user.id)
    rescue StandardError => e
      Raven.capture_exception(e)
      flash[:error] = e.message
      redirect_to items_path
      return
    end

    if @item.blank?
      flash[:error] = "No item was found with barcode #{params[:item][:barcode]}"
      redirect_to items_path
      return
    end

    redirect_to show_item_path(id: @item.id)
  end

  def show
    @item = Item.find(params[:id])
  end

  def item_detail
    item = Item.where(barcode: params[:barcode]).take
    @item = ItemViewPresenter.new(item)
    if item
      @history = ActivityLogQuery.item_history(item)
      @usage = ActivityLogQuery.item_usage(item)
    end
  end

  def restock
    item_id = params[:id]
    barcode = params[:barcode]

    results = ItemRestock.call(current_user.id, item_id, barcode)

    flash[:error] = results[:error]
    flash[:notice] = results[:notice]
    redirect_to results[:path]
  end

  def wrong_restock
    @item = Item.find(params[:id])
  end

  def issues
    @issues = UnresolvedIssueQuery.call(params)
  end

  def resolve
    issue = Issue.find(params[:issue_id])
    item = Item.where(barcode: issue.barcode).take!
    ResolveIssue.call(item: item, user: current_user, issue: issue)

    redirect_to issues_path
  end

  def refresh
    item_barcode = params[:barcode]
    if IsValidItem.call(item_barcode)
      item = Item.where(barcode: item_barcode).take
      if item.nil?
        item = Item.create!(barcode: item_barcode, thickness: 0)
        ActivityLogger.create_item(item: item, user: current_user)
      end
      success = SyncItemMetadata.call(item: item, user_id: current_user.id)
      unless success
        SyncItemMetadata.call(item: item, user_id: current_user.id, background: true)
        flash[:error] = I18n.t("item.metadata_status.error", barcode: item_barcode)
      end
    else
      flash[:error] = I18n.t("errors.barcode_not_valid", barcode: item_barcode)
    end

    redirect_to item_detail_path(barcode: item_barcode)
  end
end
