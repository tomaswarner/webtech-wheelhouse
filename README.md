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

then open http://localhost:3000, the services page should show the full price list from the
database.

`bin/rails server` also starts the app, but it won't rebuild the bootstrap css if you change it, so
use `bin/dev` instead.

## what's here so far

this is lab 8. every record can be created, edited and deleted from the browser: customers, bikes,
repairs, services and staff all have the seven restful actions, one form partial each, strong
parameters, a flash after every write and a 422 with the errors next to the field when a save is
refused.

a few decisions worth knowing about:

a new repair comes with 3 empty service lines, which covers almost every visit (the seed has at
most 4). editing a repair always adds 1 more empty line, so to add more you save and edit again. no
javascript needed. a line left on "no service" is ignored, and an existing line has a remove box.

the repair form doesn't ask for the customer. the customer is whoever owns the bike, so the model
copies it from the bike when the repair is saved or the bike changes. asking for both would let
them disagree.

the mechanic select only offers staff whose role is mechanic, and can be left on unassigned.

deleting a customer who still has bikes, or a service that has already been charged, is refused and
the page says why. deleting a bike takes its repairs with it, and deleting a staff member leaves
their repairs unassigned.

`notes` and `photos` aren't in the schema yet, they arrive in lab 9.
