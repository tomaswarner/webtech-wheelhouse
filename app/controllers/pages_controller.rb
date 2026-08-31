class PagesController < ApplicationController
  def home
  end

  def services
    @services = [
      { name: "Tune-up", price: 15000 },
      { name: "Wheel true", price: 6000 },
      { name: "Brake bleed", price: 9000 },
      { name: "Chain replacement", price: 11000 },
      { name: "Cable replacement", price: 8500 },
      { name: "Housing replacement", price: 12000 },
      { name: "Tire replacement", price: 10000 },
      { name: "Tube replacement", price: 5000 },
      { name: "Derailleur adjustment", price: 7000 },
      { name: "Headset overhaul", price: 13000 },
      { name: "Bottom bracket service", price: 14000 },
      { name: "Spoke replacement", price: 4000 }
    ]
  end

  def visit
  end

  def about
  end
end