# Decisions

Three questions I'd ask the owner if he were in the room, picked because the answer changes the
model, not just the wording.

## 1. When a bike is sold to a second owner, do we log the sale itself?

**Assumption made to keep working:** no. `bikes.customer_id` is just updated to point at the new
owner. The bike's repair history stays attached to `repairs.bike_id`, so the second owner still sees
everything done to the bike regardless of who owned it at the time.

**What changes if the answer is the other way:** if the owner wants to know *when* a bike changed
hands, a single `customer_id` column on `bikes` can't hold that — it only remembers the current
owner, not the history of owners. That would need a separate `ownership_transfers` table (bike,
previous customer, new customer, date).

## 2. Can a repair include a job that isn't on the standard price list?

**Assumption made to keep working:** no. Every `repair_line_items` row points at a real
`service_types` row — a mechanic can charge less than list price, but every job charged has a name
and a price that exists on the wall list.

**What changes if the answer is the other way:** if the shop sometimes does genuinely custom,
one-off jobs, `repair_line_items.service_type_id` would have to become optional, and the table would
need its own `description` and `price` fields for jobs with no matching `service_types` row.

## 3. Is customer approval ever skipped for very small jobs?

**Assumption made to keep working:** yes. The owner's own example is a flat tyre that "goes out the
same afternoon" — the lifecycle lets a repair move `diagnosing → in_progress` directly for trivial
jobs.

**What changes if the answer is the other way:** if every job needs a yes from the customer, however
small, that shortcut transition gets removed from the lifecycle, and `awaiting_approval` becomes a
mandatory state every repair passes through.