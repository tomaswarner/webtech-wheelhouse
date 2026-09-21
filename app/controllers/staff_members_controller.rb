class StaffMembersController < ApplicationController
  def index
    @staff_members = StaffMember.order(:name)
  end

  def show
    @staff_member = StaffMember.find(params[:id])
  end
end
