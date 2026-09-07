# Wipe everything so running this file twice leaves the same row counts.
RepairLineItem.delete_all
Repair.delete_all
Bike.delete_all
ServiceType.delete_all
StaffMember.delete_all
Customer.delete_all

# --- Services (the wall list) -------------------------------------------

services_data = [
  ["Tune-up", 15000],
  ["Wheel true", 6000],
  ["Brake bleed", 9000],
  ["Chain replacement", 11000],
  ["Cable replacement", 8500],
  ["Housing replacement", 12000],
  ["Tire replacement", 10000],
  ["Tube replacement", 5000],
  ["Derailleur adjustment", 7000],
  ["Headset overhaul", 13000],
  ["Bottom bracket service", 14000],
  ["Spoke replacement", 4000],
  ["Wheel replacement", 45000],
  ["Full bike wash", 8000],
  ["Lubrication service", 5000],
  ["Pedal replacement", 6000],
  ["Saddle replacement", 7000],
  ["Handlebar tape replacement", 4000],
  ["Disc brake pad replacement", 9000],
  ["Suspension fork service", 25000]
]

services = services_data.each_with_object({}) do |(name, price), hash|
  hash[name] = ServiceType.create!(name: name, current_price: price)
end

# --- Staff -------------------------------------------------------------

pedro   = StaffMember.create!(name: "Pedro Soto", role: "mechanic")
ana     = StaffMember.create!(name: "Ana Muñoz", role: "mechanic")
felipe  = StaffMember.create!(name: "Felipe Rojas", role: "mechanic")
camila_staff = StaffMember.create!(name: "Camila Fuentes", role: "counter")

# --- Customers -----------------------------------------------------------

eduardo   = Customer.create!(name: "Eduardo Carrasco", phone: "+56911111111")
paloma    = Customer.create!(name: "Paloma Godoy", phone: "+56922222222")
tomas     = Customer.create!(name: "Tomas Warner", phone: "+56933333333")
andres    = Customer.create!(name: "Andres Silva", phone: "+56944444444")
ignacio   = Customer.create!(name: "Ignacio Valdez", phone: "+56955555555")
isidora   = Customer.create!(name: "Isidora Valenzuela", phone: "+56966666666")
jose      = Customer.create!(name: "Jose Gonzalez", phone: "+56977777777")
fernando  = Customer.create!(name: "Fernando Zampedri", phone: "+56988888888")
clemente  = Customer.create!(name: "Clemente Ramirez", phone: "+56999999999")
justo     = Customer.create!(name: "Justo Giani", phone: "+56900000001")
josepedro = Customer.create!(name: "Jose Pedro Martinez", phone: "+56900000002")

# --- Bikes -----------------------------------------------------------------
# bike1 and bike3 are the two blue Trek Marlins from the owner's story:
# same make and model, different serial number, different owners.

bike1  = Bike.create!(customer_id: eduardo.id,   make: "Trek",        model: "Marlin",       serial_number: "WH-1001")
bike2  = Bike.create!(customer_id: eduardo.id,   make: "Giant",       model: "Escape",       serial_number: "WH-1002")
bike3  = Bike.create!(customer_id: paloma.id,    make: "Trek",        model: "Marlin",       serial_number: "WH-1003")
bike4  = Bike.create!(customer_id: tomas.id,     make: "Specialized", model: "Allez",        serial_number: "WH-1004")
bike5  = Bike.create!(customer_id: andres.id,    make: "Cannondale",  model: "Quick",        serial_number: "WH-1005")
bike6  = Bike.create!(customer_id: ignacio.id,   make: "Giant",       model: "Defy",         serial_number: "WH-1006")
bike7  = Bike.create!(customer_id: isidora.id,   make: "Scott",       model: "Aspect",       serial_number: "WH-1007")
bike8  = Bike.create!(customer_id: jose.id,      make: "Trek",        model: "Domane",       serial_number: "WH-1008")
bike9  = Bike.create!(customer_id: fernando.id,  make: "Merida",      model: "Ride",         serial_number: "WH-1009")
bike10 = Bike.create!(customer_id: clemente.id,  make: "Bianchi",     model: "Via Nirone",   serial_number: "WH-1010")
bike11 = Bike.create!(customer_id: justo.id,     make: "Cube",        model: "Attain",       serial_number: "WH-1011")
bike12 = Bike.create!(customer_id: josepedro.id, make: "Orbea",       model: "Avant",        serial_number: "WH-1012")

# --- Repairs ---------------------------------------------------------------

def add_service(repair, service, price_charged: nil)
  RepairLineItem.create!(
    repair_id: repair.id,
    service_type_id: service.id,
    price_charged: price_charged || service.current_price
  )
end

# 1. Just dropped off, nothing diagnosed yet: no mechanic assigned, no
#    line items, because nothing has been quoted. This is the one
#    intentional exception to "every repair has 1-4 services" (see
#    docs/domain-model.md, lifecycle notes).
r1 = Repair.create!(
  bike_id: bike1.id, customer_id: eduardo.id,
  status: "dropped_off",
  dropped_off_at: Time.current,
  promised_on: 2.days.from_now.to_date
)

# 2. Being examined right now.
r2 = Repair.create!(
  bike_id: bike2.id, customer_id: eduardo.id, staff_member_id: pedro.id,
  status: "diagnosing",
  dropped_off_at: 1.day.ago,
  promised_on: 1.day.from_now.to_date
)
add_service(r2, services["Tune-up"])
add_service(r2, services["Brake bleed"])

# 3. Quoted, waiting on the customer.
r3 = Repair.create!(
  bike_id: bike3.id, customer_id: paloma.id, staff_member_id: ana.id,
  status: "awaiting_approval",
  dropped_off_at: 2.days.ago,
  promised_on: 3.days.from_now.to_date
)
add_service(r3, services["Housing replacement"])
add_service(r3, services["Cable replacement"])

# 4. Customer said no.
r4 = Repair.create!(
  bike_id: bike4.id, customer_id: tomas.id, staff_member_id: felipe.id,
  status: "declined",
  dropped_off_at: 4.days.ago,
  promised_on: 1.day.ago.to_date
)

# 5. Approved, work underway.
r5 = Repair.create!(
  bike_id: bike5.id, customer_id: andres.id, staff_member_id: pedro.id,
  status: "in_progress",
  dropped_off_at: 2.days.ago,
  promised_on: 1.day.from_now.to_date
)
add_service(r5, services["Chain replacement"])
add_service(r5, services["Derailleur adjustment"])

# 6. Ready, but the promised day has already passed and it hasn't been
#    picked up. This is the overdue case.
r6 = Repair.create!(
  bike_id: bike6.id, customer_id: ignacio.id, staff_member_id: ana.id,
  status: "ready",
  dropped_off_at: 6.days.ago,
  promised_on: 1.day.ago.to_date
)
add_service(r6, services["Wheel true"])
add_service(r6, services["Brake bleed"])

# 7. Same-day in and out: a flat tyre.
r7 = Repair.create!(
  bike_id: bike7.id, customer_id: isidora.id, staff_member_id: felipe.id,
  status: "picked_up",
  dropped_off_at: Time.current.beginning_of_day + 9.hours,
  promised_on: Date.current,
  picked_up_at: Time.current.beginning_of_day + 15.hours
)
add_service(r7, services["Tube replacement"])

# 8. Second repair on bike1, months ago: this is the bike with more than
#    one repair, on different dates.
r8 = Repair.create!(
  bike_id: bike1.id, customer_id: eduardo.id, staff_member_id: pedro.id,
  status: "picked_up",
  dropped_off_at: 40.days.ago,
  promised_on: 39.days.ago.to_date,
  picked_up_at: 38.days.ago
)
add_service(r8, services["Tune-up"])

# 9. From before last January: charged the price the list had back then,
#    not what the list says today.
r9 = Repair.create!(
  bike_id: bike8.id, customer_id: jose.id, staff_member_id: ana.id,
  status: "picked_up",
  dropped_off_at: 13.months.ago,
  promised_on: (13.months.ago + 1.day).to_date,
  picked_up_at: 13.months.ago + 2.days
)
add_service(r9, services["Tune-up"], price_charged: 12000)
add_service(r9, services["Wheel true"], price_charged: 5000)

# 10. Picked up, four jobs on one visit.
r10 = Repair.create!(
  bike_id: bike9.id, customer_id: fernando.id, staff_member_id: felipe.id,
  status: "picked_up",
  dropped_off_at: 10.days.ago,
  promised_on: 9.days.ago.to_date,
  picked_up_at: 8.days.ago
)
add_service(r10, services["Bottom bracket service"])
add_service(r10, services["Headset overhaul"])
add_service(r10, services["Spoke replacement"])
add_service(r10, services["Chain replacement"])

# 11. Approved, in progress.
r11 = Repair.create!(
  bike_id: bike10.id, customer_id: clemente.id, staff_member_id: ana.id,
  status: "in_progress",
  dropped_off_at: 3.days.ago,
  promised_on: 2.days.from_now.to_date
)
add_service(r11, services["Disc brake pad replacement"])

# 12. Being examined, mechanic already knows it needs a new wheel.
r12 = Repair.create!(
  bike_id: bike11.id, customer_id: justo.id, staff_member_id: pedro.id,
  status: "diagnosing",
  dropped_off_at: Time.current,
  promised_on: 4.days.from_now.to_date
)
add_service(r12, services["Wheel replacement"])

# 13. Second, older repair on bike2.
r13 = Repair.create!(
  bike_id: bike2.id, customer_id: eduardo.id, staff_member_id: felipe.id,
  status: "picked_up",
  dropped_off_at: 20.days.ago,
  promised_on: 19.days.ago.to_date,
  picked_up_at: 18.days.ago
)
add_service(r13, services["Lubrication service"])
add_service(r13, services["Full bike wash"])

# 14. Second, older repair on bike5.
r14 = Repair.create!(
  bike_id: bike5.id, customer_id: andres.id, staff_member_id: pedro.id,
  status: "picked_up",
  dropped_off_at: 15.days.ago,
  promised_on: 14.days.ago.to_date,
  picked_up_at: 13.days.ago
)
add_service(r14, services["Pedal replacement"])
add_service(r14, services["Saddle replacement"])

# 15. Second, older repair on bike6.
r15 = Repair.create!(
  bike_id: bike6.id, customer_id: ignacio.id, staff_member_id: ana.id,
  status: "picked_up",
  dropped_off_at: 25.days.ago,
  promised_on: 24.days.ago.to_date,
  picked_up_at: 23.days.ago
)
add_service(r15, services["Handlebar tape replacement"])

# 16. Second repair on bike7, still waiting on the customer.
r16 = Repair.create!(
  bike_id: bike7.id, customer_id: isidora.id, staff_member_id: felipe.id,
  status: "awaiting_approval",
  dropped_off_at: 1.day.ago,
  promised_on: 2.days.from_now.to_date
)
add_service(r16, services["Suspension fork service"])

# josepedro (bike12) is left with no repairs at all on purpose.

puts "Seeded #{ServiceType.count} services, #{StaffMember.count} staff, " \
     "#{Customer.count} customers, #{Bike.count} bikes, " \
     "#{Repair.count} repairs, #{RepairLineItem.count} line items."