class BinsController < ApplicationController
  def index
    @bins = Bin.includes(:matches).where.not(matches: { id: nil })
  end

  def show
    @bin = Bin.find(params[:id])
  end

  def remove_match
    item = match.item
    bin = match.bin

    DestroyMatch.call(match: @match, user: current_user)

    unless can_remove_item?(bin: bin, item: item)
      flash[:warning] = "Removed transaction #{@match.request.trans}. There are remaining requests for the item."
    end

    redirect_to show_bin_path(id: bin.id)
  end

  def process_match
    item = match.item
    bin = match.bin

    ProcessMatch.call(match: @match, user: current_user)

    unless can_remove_item?(bin: bin, item: item)
      flash[:warning] = "Processed transaction #{@match.request.trans}. There are remaining requests for the item."
    end

    redirect_to show_bin_path(id: bin.id)
  end

  private

  def can_remove_item?(bin:, item:)
    bin.matches.where(item: item).empty?
  end

  def match
    @match ||= Match.find(params[:match_id])
  end
end
