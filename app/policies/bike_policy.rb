# frozen_string_literal: true

# Bikes (see docs/permissions.md, "Bikes").
# Owner: everything. Counter: create, edit, read. Mechanic: nothing.
class BikePolicy < ApplicationPolicy
  def index?
    front_desk?
  end

  def show?
    front_desk?
  end

  def create?
    front_desk?
  end

  def update?
    front_desk?
  end

  def destroy?
    owner?
  end

  def permitted_attributes
    front_desk? ? [:customer_id, :make, :model, :serial_number] : []
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      owner? || counter? ? scope.all : scope.none
    end
  end
end
