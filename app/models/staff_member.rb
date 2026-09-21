class StaffMember < ApplicationRecord
  has_many :repairs, dependent: :nullify

  validates :name, presence: true
  validates :role, presence: true

  scope :by_name, -> { order(:name) }
end
