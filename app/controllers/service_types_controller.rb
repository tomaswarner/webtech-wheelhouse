class ServiceTypesController < ApplicationController
  def index
    @services = ServiceType.order(:name)
  end

  def show
    @service = ServiceType.find(params[:id])
  end
end
