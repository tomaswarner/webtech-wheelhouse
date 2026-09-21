class ServiceType < ApplicationRecord
  has_many :repair_line_items, dependent: :restrict_with_error
  has_many :repairs, through: :repair_line_items

  validates :name, presence: true, uniqueness: true
  validates :current_price, presence: true, numericality: { greater_than: 0 }

  scope :by_name, -> { order(:name) }
end
