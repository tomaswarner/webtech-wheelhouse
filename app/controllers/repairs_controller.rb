class RepairsController < ApplicationController
  NEW_REPAIR_LINES = 3
  EXTRA_LINES = 1

  before_action :set_repair, only: [:show, :edit, :update, :destroy]
  before_action :load_choices, only: [:new, :create, :edit, :update]

  def index
    @repairs = policy_scope(Repair).newest_first.includes(:bike, :customer, taken_in_by: :staff_member).with_attached_intake_photos.with_rich_text_diagnosis
  end

  def show
  end

  def new
    @repair = authorize Repair.new(bike_id: params[:bike_id], dropped_off_at: Time.current.change(sec: 0))
    add_blank_lines(NEW_REPAIR_LINES)
  end

  def create
    @repair = authorize Repair.new
    attributes = permitted_attributes(@repair)
    @repair.assign_attributes(attributes.except(:intake_photos))
    @repair.add_intake_photos(attributes[:intake_photos])
    @repair.taken_in_by = Current.user # from the session, never from the form

    if @repair.save
      redirect_to @repair, notice: "Repair #{@repair} was taken in."
    else
      add_blank_lines(EXTRA_LINES)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    add_blank_lines(EXTRA_LINES)
  end

  # set_repair already ran authorize (update?), so a refused request stops
  # before this line and writes nothing. The attribute list comes from the
  # policy: a mechanic's hand-added repair[staff_member_id] or price_charged
  # is dropped and the rest of the request goes on.
  def update
    attributes = permitted_attributes(@repair)
    @repair.assign_attributes(attributes.except(:intake_photos))
    @repair.add_intake_photos(attributes[:intake_photos])

    if @repair.save
      redirect_to @repair, notice: "Repair #{@repair} was updated."
    else
      add_blank_lines(EXTRA_LINES)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @repair.destroy
      redirect_to repairs_path, notice: "Repair #{@repair} was deleted, with its services.", status: :see_other
    else
      redirect_to @repair, alert: "Repair #{@repair} was not deleted: #{@repair.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_repair
    @repair = authorize Repair.with_attached_intake_photos.with_rich_text_diagnosis.includes(:customer, :staff_member, taken_in_by: :staff_member, bike: :customer, repair_line_items: :service_type).find(params[:id])
  end

  def load_choices
    @bikes = Bike.by_make_and_model.includes(:customer)
    @mechanics = StaffMember.mechanics.or(StaffMember.where(id: @repair&.staff_member_id)).by_name
    @service_types = ServiceType.by_name
  end

  def add_blank_lines(count)
    count.times { @repair.repair_line_items.build }
  end
end
