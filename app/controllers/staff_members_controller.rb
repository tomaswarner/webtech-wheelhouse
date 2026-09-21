class StaffMembersController < ApplicationController
  def index
    @staff_members = StaffMember.by_name
  end

  def show
    @staff_member = StaffMember.find(params[:id])
  end
end
