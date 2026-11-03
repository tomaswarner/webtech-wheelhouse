# frozen_string_literal: true

# Base policy: every question answers false unless a subclass says otherwise.
# An action without a written method is therefore refused (403).
#
# `user` is the signed-in account (Current.user, handed over by
# ApplicationController#pundit_user). It is nil for a visitor on a public page,
# so every helper below is nil-safe. No policy reads the session, params or
# Current directly, and no role name is written as a string: the enum's
# predicate methods (owner?, counter?, mechanic?) are used instead.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  # Attributes a person may write through a form. Nothing by default.
  def permitted_attributes
    []
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # Deny by default: a scope that is not written returns no rows.
    def resolve
      scope.none
    end

    private

    attr_reader :user, :scope

    def signed_in?
      user.present?
    end

    def owner?
      user&.owner? || false
    end

    def counter?
      user&.counter? || false
    end

    def mechanic?
      user&.mechanic? || false
    end
  end

  private

  def signed_in?
    user.present?
  end

  def owner?
    user&.owner? || false
  end

  def counter?
    user&.counter? || false
  end

  def mechanic?
    user&.mechanic? || false
  end

  # Owner and counter run the front of the shop.
  def front_desk?
    owner? || counter?
  end
end
