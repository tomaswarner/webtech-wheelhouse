class Customer < ApplicationRecord
  has_many :bikes, dependent: :restrict_with_error
  has_many :repairs, through: :bikes

  validates :name, presence: true
  validates :phone, presence: true, uniqueness: true
end
