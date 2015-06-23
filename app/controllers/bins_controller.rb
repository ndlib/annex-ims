class BinsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bins = Bin.includes(:matches).where.not(matches: { id: nil })
  end

  def show
    @bin = Bin.find(params[:id])
  end

  def remove
    @match = Match.find(params[:match_id])
    bin_id = @match.bin.id

    LogActivity.call(@match.item, "Dissociated", @match.item.bin, Time.now, current_user)

    @match.item.bin = nil
    @match.item.save!
    @match.bin = nil
    @match.save!

    ApiPostDeliverItem.call(@match.id, current_user)

    redirect_to show_bin_path(:id => bin_id)
  end

end
