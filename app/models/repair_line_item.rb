class RepairLineItem < ApplicationRecord
  belongs_to :repair
  belongs_to :service_type

  validates :price_charged,
    presence: { message: ->(item, _) { "on the #{item.line_name} line can't be blank" } },
    numericality: { greater_than: 0, allow_nil: true, message: ->(item, _) { "on the #{item.line_name} line must be greater than 0" } }

  def line_name
    service_type&.name || "unnamed"
  end
end
