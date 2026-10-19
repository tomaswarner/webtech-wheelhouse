# wheelhouse API

A versioned JSON API for two programs that are not a browser: the shop's website, which shows the
price list, and the accounting program, which reads the repairs. Every route is under `/api/v1`, and
every response, errors included, is `application/json`.

## routes

| verb | path | token | statuses |
| --- | --- | --- | --- |
| GET | `/api/v1/services` | no | 200 |
| GET | `/api/v1/services/:id` | no | 200, 404 |
| POST | `/api/v1/services` | yes | 201, 400, 401, 422 |
| GET | `/api/v1/repairs` | yes | 200, 400 (unknown `state`), 401 |
| GET | `/api/v1/repairs/:id` | yes | 200, 401, 404 |

Any other path under `/api/v1` answers 404, and a request whose query string or JSON body can't be
read answers 400.

The token goes in the `Authorization` header with the `Bearer` scheme:
`Authorization: Bearer <token>`. A token in the query string or in the body is not read. The token
is checked before the action runs, so a request without it never reaches the database.

`GET /api/v1/repairs?state=ready` answers only the repairs in that state. The states are
`dropped_off`, `diagnosing`, `awaiting_approval`, `in_progress`, `declined`, `ready` and
`picked_up`. The collection is ordered newest first and has no pages.

`POST /api/v1/services` takes a JSON body, either `{"name": "...", "price": "..."}` or the same
inside a `service` key. Any other attribute is dropped. The answer carries a `Location` header with
the URL of the new service.

Browsers on other origins: only `https://tomaswarner.github.io` and `http://localhost:5500` may
read `GET /api/v1/services` and `GET /api/v1/services/:id`. No origin is allowed to call the routes
that need the token. A request with no `Origin` header (`curl`) is answered as always.

## documents

A service. `repairs_count` is the number of different repairs the service has been charged on; it is
not a column.

```json
{
  "id": 1,
  "name": "Tune-up",
  "price": "15000.00",
  "repairs_count": 3
}
```

A repair.

```json
{
  "id": 5,
  "state": "in_progress",
  "received_on": "2026-10-17",
  "promised_on": "2026-10-20",
  "handed_back_on": null,
  "bike": { "make": "Cannondale", "model": "Quick", "serial_number": "WH-1005" },
  "customer": { "name": "Andres Silva" },
  "lines": [
    { "service": "Chain replacement", "price_charged": "11000.00" },
    { "service": "Derailleur adjustment", "price_charged": "7000.00" }
  ],
  "total": "18000.00",
  "overdue": false,
  "customer_answer": "approved"
}
```

`total`, `overdue` and `customer_answer` are not columns. `customer_answer` is the quote's answer as
the lifecycle names it: `awaiting_approval` while the customer has not answered, `approved` while the
work is `in_progress` or `ready`, `declined` after a no, and `null` before a quote exists and once
the bike is `picked_up`, because from then on the state no longer says what the answer was.

A collection of repairs is a JSON array of those documents (`GET /api/v1/repairs`), and a collection
of services is a JSON array of services.

An error. Every error, whatever its status, has this shape: one key, a list of strings.

```json
{ "errors": ["There is no repair with id 9999"] }
```

A refused service answers 422 with the sentences of the validations, the same ones the form shows:

```json
{ "errors": ["Name can't be blank", "Price must be greater than 0"] }
```

## decisions

**A price travels as a string with two decimals** (`"15000.00"`), in services, in the lines of a
repair and in `total`. The columns are decimals, and a JSON number is read by most programs as a
float, which can't hold every amount exactly. A program that adds prices up (the accounting
program) should parse the string into a decimal type. The same rule applies to the price sent in a
`POST`: `"900"` and `900` are both read as 900.00.

**What a repair leaves out, and why.**

- `bike_id`, `customer_id` and `mechanic_id` (any foreign key): they mean nothing outside the
  database. The bike and the customer's name come inside the document instead.
- The customer's phone: the accounting program bills a name and a bike, it doesn't call anyone, and
  a phone number is personal data nobody asked for.
- The mechanic, the diagnosis and the intake photos: they are how the shop works, not what was
  charged.
- `created_at` and `updated_at`: the three days that matter (`received_on`, `promised_on`,
  `handed_back_on`) are already in the document, as days, not instants.
- The ids of the lines: a line is only read as part of its repair.

**The document is written by the controller**, key by key, and not by `to_json` on a model, so a
column added later does not reach a client by accident.

**The version is a segment of the path.** A change that breaks a client goes to `/api/v2`; `/api/v1`
keeps answering as documented here.
