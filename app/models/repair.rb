class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :staff_member
  has_many :repair_line_items
end