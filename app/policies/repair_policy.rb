# frozen_string_literal: true

# Repairs (see docs/permissions.md, "Repairs").
#
# - Owner: reads, takes in, edits and deletes every repair.
# - Counter: reads every repair, takes in, edits every repair that is not
#   handed back. Never deletes.
# - Mechanic: reads and edits only their own repairs (repairs.staff_member_id
#   equals the staff member linked to the account), and only while they are
#   not handed back. Never takes in or deletes. A mechanic account with no
#   linked staff member has no repairs.
#
# "Handed back" is the final state of the lifecycle in docs/domain-model.md:
# picked_up. Only the owner edits a handed-back repair.
class RepairPolicy < ApplicationPolicy
  FRONT_DESK_ATTRIBUTES = [
    :bike_id, :staff_member_id, :status, :dropped_off_at, :promised_on,
    :picked_up_at, :diagnosis,
    { intake_photos: [] },
    { repair_line_items_attributes: [:id, :service_type_id, :price_charged, :_destroy] }
  ].freeze

  # A mechanic changes the state and the diagnosis, and adds intake photos.
  MECHANIC_ATTRIBUTES = [:status, :diagnosis, { intake_photos: [] }].freeze

  # Every signed-in account opens the list; the scope decides what is in it.
  def index?
    signed_in?
  end

  def show?
    front_desk? || own_repair?
  end

  # Taking in a repair.
  def create?
    front_desk?
  end

  def update?
    return true if owner?
    return false if handed_back?

    counter? || own_repair?
  end

  def destroy?
    owner?
  end

  # Removing an intake photo (IntakePhotosController#destroy). Mechanics only
  # add photos, so removing one is a front-desk edit.
  def remove_photo?
    front_desk? && update?
  end

  def permitted_attributes
    if front_desk?
      FRONT_DESK_ATTRIBUTES
    elsif own_repair?
      MECHANIC_ATTRIBUTES
    else
      []
    end
  end

  class Scope < ApplicationPolicy::Scope
    # Same rule as show?, written as a filter. Returns a relation, so
    # newest_first, overdue, where(status: ...) and includes chain after it.
    def resolve
      if owner? || counter?
        scope.all
      elsif mechanic? && user.staff_member_id.present?
        scope.where(staff_member_id: user.staff_member_id)
      else
        scope.none
      end
    end
  end

  private

  def own_repair?
    mechanic? &&
      user.staff_member_id.present? &&
      record.respond_to?(:staff_member_id) &&
      record.staff_member_id == user.staff_member_id
  end

  def handed_back?
    record.respond_to?(:picked_up?) && record.picked_up?
  end
end
