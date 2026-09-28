class StaffMembersController < ApplicationController
  before_action :set_staff_member, only: [:show, :edit, :update, :destroy]

  def index
    @staff_members = StaffMember.by_name
  end

  def show
  end

  def new
    @staff_member = StaffMember.new
  end

  def create
    @staff_member = StaffMember.new(staff_member_params)
    if @staff_member.save
      redirect_to @staff_member, notice: "Staff member #{@staff_member.name} was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @staff_member.update(staff_member_params)
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
    @staff_member = StaffMember.includes(repairs: [:bike, :customer]).find(params[:id])
  end

  def staff_member_params
    params.expect(staff_member: [:name, :role])
  end
end
