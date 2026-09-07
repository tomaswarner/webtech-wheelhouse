# Domain model

![domain model diagram](domain-model.png)

> **before you commit this:** paste the DBML below into [dbdiagram.io](https://dbdiagram.io), export it
> as PNG, and save it as `docs/domain-model.png`, replacing the Lab 3 image — this diagram now matches
> `db/schema.rb`, not the Lab 3 draft.

```dbml
Table customers {
  id bigint [pk, increment]
  name varchar
  phone varchar [unique]
  created_at timestamp
  updated_at timestamp
}

Table staff_members {
  id bigint [pk, increment]
  name varchar
  role varchar
  created_at timestamp
  updated_at timestamp
}

Table service_types {
  id bigint [pk, increment]
  name varchar [unique]
  current_price decimal(10,2)
  created_at timestamp
  updated_at timestamp
}

Table bikes {
  id bigint [pk, increment]
  customer_id bigint
  make varchar
  model varchar
  serial_number varchar [unique]
  created_at timestamp
  updated_at timestamp
}

Table repairs {
  id bigint [pk, increment]
  bike_id bigint
  customer_id bigint
  staff_member_id bigint
  status varchar [default: 'dropped_off']
  promised_on date
  dropped_off_at timestamp
  picked_up_at timestamp
  created_at timestamp
  updated_at timestamp
}

Table repair_line_items {
  id bigint [pk, increment]
  repair_id bigint
  service_type_id bigint
  price_charged decimal(10,2)
  created_at timestamp
  updated_at timestamp
}

Ref: bikes.customer_id > customers.id
Ref: repairs.bike_id > bikes.id
Ref: repairs.customer_id > customers.id
Ref: repairs.staff_member_id > staff_members.id
Ref: repair_line_items.repair_id > repairs.id
Ref: repair_line_items.service_type_id > service_types.id
```

These `Ref` lines are for the diagram only — no foreign key is enforced by the database yet. That
constraint, and the Ruby association that uses it, is Lab 7.

## Lifecycle

A repair's `status` moves through these states:

1. `dropped_off` — bike is tagged and on the rack, no mechanic has looked at it yet.
2. `diagnosing` — a mechanic is examining it and writing the note.
3. `awaiting_approval` — the mechanic quoted a price and is waiting for the customer's yes or no.
4. `in_progress` — either the customer approved the quote, or the fix was trivial enough to skip
   straight from diagnosing.
5. `declined` — the customer said no to the quote.
6. `ready` — the work is finished and the bike is waiting to be picked up.
7. `picked_up` — the bike has left the shop, repaired or not.

`repairs.status` defaults to `dropped_off`, the first state, so a repair inserted with no status set
still starts in the right place.

Allowed transitions: `dropped_off → diagnosing`, `diagnosing → awaiting_approval`, `diagnosing →
in_progress` (trivial job), `awaiting_approval → in_progress`, `awaiting_approval → declined`,
`in_progress → ready`, `ready → picked_up`, `declined → picked_up`.

Not allowed, and why: `dropped_off → ready` or `dropped_off → in_progress` (nothing has been
diagnosed yet); `declined → in_progress` (no approval to do paid work — a changed mind starts a new
repair instead); `ready → in_progress` or `picked_up → anything` (a picked-up bike is out of the
shop's hands, and a ready one shouldn't quietly go back to being worked on without a new repair
record).

## Changes since Lab 3

- **`notes` and `photos` are gone from this diagram.** They're still part of the domain — a
  mechanic's diagnosis and the intake photos — but they arrive with Lab 9's features, so they don't
  exist in today's schema and don't belong in a diagram meant to match it.
- **`repairs.promised_at` is renamed to `repairs.promised_on`.** It always held a day, not an
  instant, and Lab 5's naming convention (`_on` for a day, `_at` for an instant) makes that explicit.
- **`repairs.staff_member_id` is new**, and nullable. The mechanic who will take a repair isn't known
  the moment a bike is dropped off, so the column can't be mandatory — it's filled in once someone
  starts diagnosing.
- **Every primary and foreign key is `bigint`**, not `integer` as drawn in Lab 3 — that's Rails'
  default id type, not a deliberate choice on my part.
- **Every table now shows `created_at` and `updated_at` explicitly**, replacing the ad-hoc
  `updated_at date` field `service_types` had in the Lab 3 draft. Rails' standard timestamps do that
  job instead.
- **Money columns show explicit precision and scale**, `decimal(10,2)`, matching what the migrations
  actually declare.

## Every entity traces back to a story

| Entity | Story it's required by |
|---|---|
| `customers` | Story 1 — record name and phone at drop-off |
| `bikes` | Story 2 — record serial number and model |
| `staff_members` | Story 6 — mechanic adds jobs; story 11 — owner's dashboard |
| `service_types` | Story 14 — price list is public; story 6 — jobs added from the list |
| `repairs` | Story 10a — status lookup; story 5 — awaiting approval |
| `repair_line_items` | Story 6 — jobs added from the price list; story 13 — price snapshot |

## Two decisions you have to defend

**The thing and the copy of the thing.** `bikes` is its own table, keyed on a unique
`serial_number`, separate from `repairs`. A repair is a *visit*; a bike is a *physical object* that
can have many visits over years. That separation is what stops the March mix-up: two blue Marlins are
two rows in `bikes` with two different serial numbers, so a repair always points at one exact bike. A
single table with a quantity column could tell you how many bikes came in, but not which one is which
when it's time to hand one back.

**Derived, or stored?** Whether a repair is overdue isn't stored anywhere — it's derived by comparing
`repairs.promised_on` to today's date whenever the dashboard loads, since storing it would go stale
the moment a day passes. On the other hand, `repair_line_items.price_charged` looks derivable — "just
look up the service type's price" — but it's stored on purpose, because `service_types.current_price`
changes every January, and if a line item only pointed at the service type without a stored price,
last year's invoices would silently reprice themselves the moment the list changes.