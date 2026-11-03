class BikesController < ApplicationController
  before_action :set_bike, only: [:show, :edit, :update, :destroy]
  before_action :load_customers, only: [:new, :create, :edit, :update]

  def index
    authorize Bike # a mechanic gets the 403 page, not an empty list
    @bikes = policy_scope(Bike).by_make_and_model.includes(:customer)
  end

  # The bike's repairs go through the same repair scope as /repairs.
  def show
    @repairs = policy_scope(Repair)
      .where(bike: @bike)
      .includes(:bike, :customer, taken_in_by: :staff_member)
      .with_attached_intake_photos
      .with_rich_text_diagnosis
  end

  def new
    @bike = authorize Bike.new(customer_id: params[:customer_id])
  end

  def create
    @bike = authorize Bike.new
    @bike.assign_attributes(permitted_attributes(@bike))

    if @bike.save
      redirect_to @bike, notice: "Bike #{@bike.serial_number} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @bike.update(permitted_attributes(@bike))
      redirect_to @bike, notice: "Bike #{@bike.serial_number} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @bike.destroy
      redirect_to bikes_path, notice: "Bike #{@bike.serial_number} was deleted, with its repairs.", status: :see_other
    else
      redirect_to @bike, alert: "Bike #{@bike.serial_number} was not deleted: #{@bike.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_bike
    @bike = authorize Bike.includes(:customer).find(params[:id])
  end

  def load_customers
    @customers = Customer.by_name
  end
end
