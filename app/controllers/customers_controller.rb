class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    authorize Customer # a mechanic gets the 403 page, not an empty list
    @customers = policy_scope(Customer).by_name
  end

  def show
  end

  def new
    @customer = authorize Customer.new
  end

  def create
    @customer = authorize Customer.new
    @customer.assign_attributes(permitted_attributes(@customer))

    if @customer.save
      redirect_to @customer, notice: "Customer #{@customer.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @customer.update(permitted_attributes(@customer))
      redirect_to @customer, notice: "Customer #{@customer.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.destroy
      redirect_to customers_path, notice: "Customer #{@customer.name} was deleted.", status: :see_other
    else
      redirect_to @customer, alert: "Customer #{@customer.name} was not deleted: #{@customer.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_customer
    @customer = authorize Customer.includes(bikes: :customer).find(params[:id])
  end
end
