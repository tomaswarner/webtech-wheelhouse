class ServiceTypesController < ApplicationController
  def index
    @services = ServiceType.by_name
  end

  def show
    @service = ServiceType.find(params[:id])
  end
end
