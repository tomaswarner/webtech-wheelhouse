class StaffMembersController < ApplicationController
  before_action :set_staff_member, only: [:show, :edit, :update, :destroy]

  def index
    @staff_members = policy_scope(StaffMember).by_name
  end

  # Every role reads a staff member's page, so the repairs listed on it go
  # through the repair scope: a mechanic opening a colleague's page sees none
  # of the colleague's repairs.
  def show
    @repairs = policy_scope(Repair)
      .where(staff_member: @staff_member)
      .newest_first
      .includes(:bike, :customer, taken_in_by: :staff_member)
      .with_attached_intake_photos
      .with_rich_text_diagnosis
  end

  def new
    @staff_member = authorize StaffMember.new
  end

  def create
    @staff_member = authorize StaffMember.new
    @staff_member.assign_attributes(permitted_attributes(@staff_member))

    if @staff_member.save
      redirect_to @staff_member, notice: "Staff member #{@staff_member.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @staff_member.update(permitted_attributes(@staff_member))
      redirect_to @staff_member, notice: "Staff member #{@staff_member.name} was updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @staff_member.destroy
      redirect_to staff_members_path, notice: "Staff member #{@staff_member.name} was deleted. Their repairs are now unassigned.", status: :see_other
    else
      redirect_to @staff_member, alert: "Staff member #{@staff_member.name} was not deleted: #{@staff_member.errors.full_messages.to_sentence}.", status: :see_other
    end
  end

  private

  def set_staff_member
    @staff_member = authorize StaffMember.find(params[:id])
  end
end
