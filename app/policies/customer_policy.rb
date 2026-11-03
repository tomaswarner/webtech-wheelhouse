# frozen_string_literal: true

# Customers (see docs/permissions.md, "Customers").
# Owner: everything. Counter: create, edit, read. Mechanic: nothing.
class CustomerPolicy < ApplicationPolicy
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
    front_desk? ? [:name, :phone] : []
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      owner? || counter? ? scope.all : scope.none
    end
  end
end
