class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :staff_member, optional: true
  has_many :repair_line_items, dependent: :destroy
  has_many :service_types, through: :repair_line_items

  enum :status, {
    dropped_off: "dropped_off",
    diagnosing: "diagnosing",
    awaiting_approval: "awaiting_approval",
    in_progress: "in_progress",
    declined: "declined",
    ready: "ready",
    picked_up: "picked_up"
  }

  validates :status, presence: true
  validates :promised_on, presence: true
  validates :dropped_off_at, presence: true

  validate :dates_are_coherent
  validate :hand_back_time_matches_state

  private

  def dates_are_coherent
    return if dropped_off_at.blank?

    if picked_up_at.present? && picked_up_at < dropped_off_at
      errors.add(:picked_up_at, "can't be before the day the bike came in")
    end

    if promised_on.present? && promised_on < dropped_off_at.to_date
      errors.add(:promised_on, "can't be before the day the bike came in")
    end
  end

  def hand_back_time_matches_state
    if picked_up? && picked_up_at.blank?
      errors.add(:picked_up_at, "must be set once the bike has been handed back")
    end

    if !picked_up? && picked_up_at.present?
      errors.add(:picked_up_at, "can't be set before the bike has been handed back")
    end
  end
end
