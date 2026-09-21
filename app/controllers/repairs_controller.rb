class RepairsController < ApplicationController
  def index
    @repairs = Repair.newest_first.includes(:bike, :customer)
  end

  def show
    @repair = Repair.includes(:bike, repair_line_items: :service_type).find(params[:id])
  end
end
