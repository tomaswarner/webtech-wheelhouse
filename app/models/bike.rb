class Bike < ApplicationRecord
  belongs_to :customer
  has_many :repairs, dependent: :destroy

  validates :make, presence: true
  validates :model, presence: true
  validates :serial_number, presence: true, uniqueness: true
end
