class BinsController < ApplicationController

  def index
    @bins = Bin.includes(:matches).where.not(matches: { id: nil })
  end

  def show
    @bin = Bin.find(params[:id])
  end

  def remove
    @match = Match.find(params[:match_id])
    bin_id = @match.bin.id

    ProcessMatch.call(match: @match, user: current_user)

    redirect_to show_bin_path(:id => bin_id)
  end

end
