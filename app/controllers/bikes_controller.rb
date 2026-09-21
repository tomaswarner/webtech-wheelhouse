class BikesController < ApplicationController
  def index
    @bikes = Bike.by_make_and_model.includes(:customer)
  end

  def show
    @bike = Bike.includes(:customer, repairs: :customer).find(params[:id])
  end
end
