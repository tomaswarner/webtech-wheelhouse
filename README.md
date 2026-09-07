# wheelhouse

wheelhouse is an app for a neighborhood bike repair shop. the idea is to take the repair notes out
of each mechanic's own notebook and put them on a screen anyone at the counter can check without
walking to the back.

who uses it:

counter staff (the owner's daughter) takes in the bike, tags it, and answers the phone when someone
asks if their bike is ready

mechanic (there are 3) diagnoses the bike, writes the notes, and adds the jobs that apply

owner sets the price list and wants to see which repairs are running late

customer drops off the bike, gets the quote, and says yes or no, all by phone, no login

website visitor just looks at the public price list

## docs

[user stories](docs/user-stories.md) user stories and acceptance criteria

[domain model](docs/domain-model.md) relational model in dbdiagram.io, a repair's lifecycle, and the design decisions that need defending

[decisions](docs/decisions.md) questions i'd ask the owner if he were in the room

[wireframes](docs/wireframes.md) low fidelity screens and the navigation graph

## prerequisites

ruby 4.0.4

rails 8.0

node 26.1.0 or newer, with yarn

postgresql running locally, with a role that can create databases

## setup

clone the repo and go into it

    git clone https://github.com/tomaswarner/webtech-wheelhouse.git
    cd webtech-wheelhouse

install ruby gems

    bundle install

install js packages

    yarn install

create the databases, load the schema and seed it

    bin/rails db:setup

`db:setup` creates the development and test databases, loads `db/schema.rb` into them, and runs
`db/seeds.rb`. on a database that already exists, use `bin/rails db:reset` instead, which drops it
first.

## running it

    bin/dev

then open http://localhost:3000 — the services page should show the full price list from the
database.

`bin/rails server` also starts the app, but it won't rebuild the bootstrap css if you change it, so
use `bin/dev` instead.

## what's here so far

this is lab 5. the schema now exists as migrations in `db/migrate/`, one model per table in
`app/models/`, and `db/seeds.rb` fills it with a workshop worth looking at. the services page reads
its data from the database instead of a hardcoded array.

no associations, no validations, no forms yet — that starts in lab 7. `notes` and `photos` aren't in
the schema yet either, they arrive in lab 9.