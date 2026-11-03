# Permissions

Who may do what in Wheelhouse. Each table matches the policy in `app/policies/`, in both directions: a rule here is in the policy, and a rule in the policy is here.

- **Roles** come from `users.role`: `owner`, `counter`, `mechanic`. A new account from sign-up gets `counter` (see `docs/decisions.md`) and has exactly the counter permissions.
- **Visitor** means no session. A visitor only reads the price list. Any other page sends them to sign in, never to the "not allowed" page.
- **Own repair**: a repair whose mechanic (`repairs.staff_member_id`) is the staff member linked to the mechanic's account. A mechanic account with no linked staff member has no own repairs.
- **Handed back**: a repair in `picked_up`, the final state of the lifecycle in `docs/domain-model.md`.
- A refused request answers **403** with the page "You are not allowed to do that." and writes nothing.
- No page lists, edits or deletes accounts, for any role.

## Services (`ServiceTypePolicy`)

| Action | Visitor | Owner | Counter | Mechanic |
|---|---|---|---|---|
| List (`index`) | Yes | Yes | Yes | Yes |
| Read (`show`) | Yes | Yes | Yes | Yes |
| Create (`new`, `create`) | No | Yes | No | No |
| Edit (`edit`, `update`) | No | Yes | No | No |
| Delete (`destroy`) | No | Yes | No | No |

Fields the owner writes: name, current price.

## Staff (`StaffMemberPolicy`)

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`) | Yes | Yes | Yes |
| Read (`show`) | Yes | Yes, but the repairs listed on the page are only the ones the counter may read (all) | Yes, but the repairs listed on the page are only the mechanic's own |
| Create (`new`, `create`) | Yes | No | No |
| Edit (`edit`, `update`) | Yes | No | No |
| Delete (`destroy`) | Yes | No | No |

Fields the owner writes: name, role.

## Customers (`CustomerPolicy`)

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`) | Yes | Yes | No |
| Read (`show`) | Yes | Yes | No |
| Create (`new`, `create`) | Yes | Yes | No |
| Edit (`edit`, `update`) | Yes | Yes | No |
| Delete (`destroy`) | Yes | No | No |

Fields owner and counter write: name, phone. A mechanic still sees a customer's name on a repair they can read, as plain text, not as a link.

## Bikes (`BikePolicy`)

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`) | Yes | Yes | No |
| Read (`show`) | Yes | Yes | No |
| Create (`new`, `create`) | Yes | Yes | No |
| Edit (`edit`, `update`) | Yes | Yes | No |
| Delete (`destroy`) | Yes | No | No |

Fields owner and counter write: customer, make, model, serial number. A mechanic still sees the bike on a repair they can read, as plain text, not as a link.

## Repairs (`RepairPolicy`)

| Action | Owner | Counter | Mechanic |
|---|---|---|---|
| List (`index`, from the policy scope) | Every repair | Every repair | Only own repairs (none if the account has no staff member) |
| Read (`show`) | Every repair | Every repair | Only own repairs |
| Take in (`new`, `create`) | Yes | Yes | No |
| Edit (`edit`, `update`) | Every repair, handed back or not | Every repair that is not handed back | Own repairs that are not handed back |
| Delete (`destroy`) | Yes | No | No |
| Remove an intake photo (`IntakePhotosController#destroy`) | Yes | Yes, if the repair is not handed back | No (mechanics only add photos) |

Fields each role writes when it may edit or take in:

| Field | Owner | Counter | Mechanic |
|---|---|---|---|
| Bike | Yes | Yes | No |
| Mechanic | Yes | Yes | No |
| Status | Yes | Yes | Yes |
| Diagnosis | Yes | Yes | Yes |
| Add intake photos | Yes | Yes | Yes |
| Promised on | Yes | Yes | No |
| Dropped off at | Yes | Yes | No |
| Picked up at | Yes | Yes | No |
| Service lines and prices charged | Yes | Yes | No |
| Taken in by | No: always the signed-in account, from the session | No | No |

A field outside the person's list (for example a hand-added `repair[staff_member_id]` or `price_charged` from a mechanic) is dropped, and the rest of the request is saved.

The same scope filters every page that lists repairs: `/repairs`, a bike's page and a staff member's page.

## Static pages (`PagePolicy`, headless)

| Action | Visitor | Owner | Counter | Mechanic |
|---|---|---|---|---|
| Home, Visit, About | No (sent to sign in) | Yes | Yes | Yes |
