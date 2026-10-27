class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :staff_member, optional: true
  belongs_to :taken_in_by, class_name: "User", optional: true
  has_many :repair_line_items, dependent: :destroy
  has_many :service_types, through: :repair_line_items

  PHOTO_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_PHOTO_SIZE = 10.megabytes
  THUMBNAIL_SIZE = [96, 72].freeze
  LARGE_SIZE = [800, 600].freeze

  has_many_attached :intake_photos do |attachable|
    attachable.variant :thumb, resize_to_fill: THUMBNAIL_SIZE
    attachable.variant :large, resize_to_limit: LARGE_SIZE
  end
  has_rich_text :diagnosis

  accepts_nested_attributes_for :repair_line_items,
    allow_destroy: true,
    reject_if: ->(attributes) { attributes["service_type_id"].blank? }

  enum :status, {
    dropped_off: "dropped_off",
    diagnosing: "diagnosing",
    awaiting_approval: "awaiting_approval",
    in_progress: "in_progress",
    declined: "declined",
    ready: "ready",
    picked_up: "picked_up"
  }, validate: true

  before_validation :take_customer_from_bike

  validates :status, presence: true
  validates :promised_on, presence: true
  validates :dropped_off_at, presence: true

  validate :dates_are_coherent
  validate :hand_back_time_matches_state
  validate :intake_photos_are_small_images

  scope :open, -> { where.not(status: :picked_up) }
  scope :overdue, -> { open.where(promised_on: ...Date.current) }
  scope :newest_first, -> { order(dropped_off_at: :desc) }

  def overdue?
    !picked_up? && promised_on < Date.current
  end

  def total
    repair_line_items.sum(:price_charged)
  end

  # Assigning to a has_many_attached replaces what is there, so the photos the
  # repair already has go back in along with the new files. No files, no change.
  def add_intake_photos(files)
    files = Array(files).compact_blank
    self.intake_photos = intake_photos.map(&:blob) + files if files.any?
  end

  def saved_intake_photos
    intake_photos.select(&:persisted?)
  end

  def to_s
    "##{id} (#{bike.make} #{bike.model}, #{bike.serial_number})"
  end

  private

  def intake_photos_are_small_images
    intake_photos.reject(&:persisted?).each do |photo|
      name = photo.filename.to_s

      unless PHOTO_TYPES.include?(photo.content_type)
        errors.add(:intake_photos, "#{name} is not a JPEG, PNG or WebP image")
      end

      if photo.byte_size > MAX_PHOTO_SIZE
        errors.add(:intake_photos, "#{name} is over the #{MAX_PHOTO_SIZE / 1.megabyte} MB limit")
      end
    end
  end

  def take_customer_from_bike
    self.customer = bike.customer if bike && (customer.nil? || bike_id_changed?)
  end

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
