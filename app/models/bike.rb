class Bike < ApplicationRecord
  belongs_to :customer
  has_many :repairs, dependent: :destroy

  validates :make, presence: true
  validates :model, presence: true
  validates :serial_number, presence: true, uniqueness: true

  before_validation :normalize_serial_number

  scope :by_make_and_model, -> { order(:make, :model) }

  private

  def normalize_serial_number
    self.serial_number = serial_number.strip.upcase if serial_number.present?
  end
end
