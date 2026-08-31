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

create the databases

    bin/rails db:create

## running it

    bin/dev

then open http://localhost:3000

`bin/rails server` also starts the app, but it won't rebuild the bootstrap css if you change it, so use `bin/dev` instead.

## what's here so far

this is lab 4. the app has 4 pages (home, services, visiting the workshop, about), a hand written controller and routes, and a bootstrap layout with a navbar. no database tables yet, no models, no forms. that starts in lab 5, using the domain model from `docs/domain-model.md`.