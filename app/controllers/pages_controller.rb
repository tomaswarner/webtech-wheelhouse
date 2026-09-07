class PagesController < ApplicationController
  def home
  end

def services
  @services = ServiceType.order(:name)
end

  def visit
  end

  def about
  end
end