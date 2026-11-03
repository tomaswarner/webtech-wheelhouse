# frozen_string_literal: true

# Staff (see docs/permissions.md, "Staff").
# Every signed-in role reads the staff. Only the owner creates, edits, deletes.
class StaffMemberPolicy < ApplicationPolicy
  def index?
    signed_in?
  end

  def show?
    signed_in?
  end

  def create?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

  def permitted_attributes
    owner? ? [:name, :role] : []
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      signed_in? ? scope.all : scope.none
    end
  end
end
