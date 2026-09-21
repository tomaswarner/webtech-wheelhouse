class ServiceType < ApplicationRecord
  has_many :repair_line_items
end