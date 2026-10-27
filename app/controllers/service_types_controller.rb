class ServiceTypesController < ApplicationController
  # The price list is public; creating, editing and deleting a service are not.
  allow_unauthenticated_access only: %i[index show]

  before_action :set_service_type, only: [:show, :edit, :update, :destroy]

  def index
    @service_types = ServiceType.by_name
  end

  def show
  end

  def new
    @service_type = ServiceType.new
  end

  def create
    @service_type = ServiceType.new(service_type_params)
    if @service_type.save
      redirect_to @service_type, notice: "Service #{@service_type.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service_type.update(service_type_params)
      redirect_to @service_type, notice: "Service #{@service_type.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @service_type.destroy
      redirect_to service_types_path, notice: "Service #{@service_type.name} was deleted.", status: :see_other
    else
      redirect_to @service_type, alert: "Service #{@service_type.name} was not deleted: #{@service_type.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_service_type
    @service_type = ServiceType.find(params[:id])
  end

  def service_type_params
    params.expect(service_type: [:name, :current_price])
  end
end
