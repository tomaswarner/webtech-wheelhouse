# frozen_string_literal: true

# Headless policy for the static pages (PagesController: home, visit, about).
# They are not public (Lab 11 closed them), so any signed-in account opens them.
# Used as `authorize :page` in the controller and `policy(:page).home?` in views.
class PagePolicy < ApplicationPolicy
  def home?
    signed_in?
  end

  def visit?
    signed_in?
  end

  def about?
    signed_in?
  end
end
