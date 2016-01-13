class BinsController < ApplicationController
  def index
    @bins = Bin.includes(:matches).where.not(matches: { id: nil })
  end

  def show
    @bin = Bin.find(params[:id])
  end

  def remove_match
    @match = Match.find(params[:match_id])
    ActiveRecord::Base.transaction do
      DestroyMatch.call(match: @match, user: current_user)
      try_dissociate_item_and_bin(warning_verb: "Removed")
    end

    redirect_to show_bin_path(id: @match.bin.id)
  end

  def process_match
    @match = Match.find(params[:match_id])
    bin = @match.bin
    ActiveRecord::Base.transaction do
      ProcessMatch.call(match: @match, user: current_user)
      try_dissociate_item_and_bin(warning_verb: "Processed")
    end

    redirect_to show_bin_path(id: bin.id)
  end

  private

  def try_dissociate_item_and_bin(warning_verb:)
    unless DissociateItemFromBin.call(item: @match.item, user: current_user)
      flash[:warning] = "#{warning_verb} transaction #{@match.request.trans}. There are remaining requests for the item."
    end
  end
end
