class User < ApplicationRecord
  MIN_PASSWORD_LENGTH = 10

  has_secure_password
  has_many :sessions, dependent: :destroy
  belongs_to :staff_member, optional: true

  enum :role, { owner: "owner", mechanic: "mechanic", counter: "counter" }, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :password, length: { minimum: MIN_PASSWORD_LENGTH }, allow_nil: true
  validates :staff_member_id, uniqueness: true, allow_nil: true

  # The name of the member of the staff, or the email address when the account has none.
  def display_name
    staff_member&.name || email_address
  end
end
