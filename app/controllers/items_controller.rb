class ItemsController < ApplicationController
  def index
    @item = Item.new
  end

  def scan
    begin
      @item = GetItemFromBarcode.call(barcode: params[:item][:barcode], user_id: current_user.id)
    rescue StandardError => e
      notify_airbrake(e)
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
end
