class ServiceTypesController < ApplicationController
  # The price list stays public (docs/decisions.md). The actions still ask the
  # policy, which answers true for a visitor.
  allow_unauthenticated_access only: %i[index show]
  before_action :set_service_type, only: [:show, :edit, :update, :destroy]

  def index
    @service_types = policy_scope(ServiceType).by_name
  end

  def show
  end

  def new
    @service_type = authorize ServiceType.new
  end

  def create
    @service_type = authorize ServiceType.new
    @service_type.assign_attributes(permitted_attributes(@service_type))

    if @service_type.save
      redirect_to @service_type, notice: "Service #{@service_type.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service_type.update(permitted_attributes(@service_type))
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
    @service_type = authorize ServiceType.find(params[:id])
  end
end
