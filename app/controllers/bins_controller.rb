class BinsController < ApplicationController
  def index
    @bins = Bin.includes(:matches).where.not(matches: { id: nil })
  end

  def show
    @bin = Bin.find(params[:id])
  end

  def remove
    @match = Match.find(params[:match_id])
    item = @match.item
    bin = @match.bin

    ProcessMatch.call(match: @match, user: current_user)

    unless bin.matches.where(item: item).empty?
      flash[:warning] = "Processed transaction #{@match.request.trans}. There are remaining requests for the item."
    end

    redirect_to show_bin_path(id: bin.id)
  end
end
