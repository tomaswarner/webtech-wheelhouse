# frozen_string_literal: true

# Services, the price list (see docs/permissions.md, "Services").
# Reading is public: visitors (user is nil) and every role read it.
# Only the owner creates, edits and deletes.
class ServiceTypePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
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
    owner? ? [:name, :current_price] : []
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
