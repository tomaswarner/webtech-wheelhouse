class PagesController < ApplicationController
  # Headless policy (app/policies/page_policy.rb): any signed-in account.
  before_action { authorize :page }

  def home
  end

  def visit
  end

  def about
  end
end
