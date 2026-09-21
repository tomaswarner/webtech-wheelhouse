class RepairsController < ApplicationController
  def index
    @repairs = Repair.order(dropped_off_at: :desc)
  end

  def show
    @repair = Repair.find(params[:id])
  end
end
