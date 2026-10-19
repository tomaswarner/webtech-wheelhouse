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

[api](docs/api.md) the json api: routes, documents, status codes and the decisions behind them

## prerequisites

ruby 4.0.4

rails 8.0

node 26.7.0 or newer (see `.node-version`), with yarn

postgresql running locally (on macos `brew services start postgresql@17`), with a role that can create
databases. on debian or ubuntu create it first: `sudo -u postgres createuser --superuser $USER`

libvips, which makes the photo thumbnails. on macos `brew install vips`, on debian or ubuntu
`sudo apt install libvips42` (`libvips42t64` on recent releases, or `libvips-dev`). check it with `vips --version`.

## setup

clone the repo and go into it

    git clone https://github.com/tomaswarner/webtech-wheelhouse.git
    cd webtech-wheelhouse

install ruby gems

    bundle install

install js packages

    yarn install

build the css (it is not committed)

    yarn build:css

set the api token. it lives in the encrypted credentials, and the key that opens the committed
`config/credentials.yml.enc` is not in the repository (`config/master.key` is never committed), so
on a fresh clone make your own: delete the file, then create it again

    rm config/credentials.yml.enc
    EDITOR=nano bin/rails credentials:edit

the editor opens with a template. add one line with a long random value, save and close

    api_token: paste-the-output-of-openssl-rand-hex-32-here

`openssl rand -hex 32` prints a good value. rails writes `config/master.key` next to the credentials;
keep it out of git (it is already ignored). to see the token again when you need it

    bin/rails runner 'puts Rails.application.credentials.api_token'

create the databases, load the schema and seed it

    bin/rails db:setup

`db:setup` creates the development and test databases, loads `db/schema.rb` into them, and runs
`db/seeds.rb`. on a database that already exists, use `bin/rails db:reset` instead, which drops it
first.

## running it

    bin/dev

then open http://localhost:3000. the repairs page (http://localhost:3000/repairs) should show a
thumbnail and the start of the diagnosis on every row; the services page shows the price list.

`bin/dev` installs foreman the first time it runs; leave it running and stop it with ctrl+c.

`bin/rails server` also starts the app, but it won't rebuild the bootstrap css if you change it, so
use `bin/dev` instead.

## the api

lab 10 adds a json api under `/api/v1` for the shop's website and the accounting program. the
routes, the shape of every document and the decisions are in [docs/api.md](docs/api.md).

reading the price list is public. reading repairs and registering a service need the token, sent as
`Authorization: Bearer <token>`.

with the app running (`bin/dev`), from another terminal

    curl http://localhost:3000/api/v1/services

    curl -H "Authorization: Bearer $(bin/rails runner 'puts Rails.application.credentials.api_token')" \
      "http://localhost:3000/api/v1/repairs?state=ready"

and to register a service

    curl -X POST http://localhost:3000/api/v1/services \
      -H "Authorization: Bearer $(bin/rails runner 'puts Rails.application.credentials.api_token')" \
      -H "Content-Type: application/json" \
      -d '{"name": "Fender install", "price": "6500"}'

### the price list on the website

the price list is read by a section of my personal page, published at
https://tomaswarner.github.io/webtech-lab-01/ (repository
[webtech-lab-01](https://github.com/tomaswarner/webtech-lab-01)).

the page looks for the api at `http://localhost:3000`, so the api has to run on **port 3000**, which
is what `bin/dev` uses. the api only answers browsers on two origins: that published page and
`http://localhost:5500`, where the page is served while developing it, for example from the
page's folder with `python3 -m http.server 5500`.

## what's here so far

this is lab 10. every record can be created, edited and deleted from the browser (lab 8), a repair
carries intake photos and a diagnosis (lab 9), and the price list and the repairs can be read as json
(lab 10).

photos use active storage, stored in the `storage/` folder (not committed). the seed attaches the
photos in `db/seeds/` (CC0, from Wikimedia Commons) to most repairs: one bike, one picture, and the three detail shots of the red road bike are crops of its side photo. a repair has any number of photos, chosen in the repair
form (several at once). only jpeg, png and webp are accepted, up to 10 MB each, checked in the
model; if any file of a request is refused nothing from that request is attached, the page comes
back with a 422 and the message under the file field names the file. photos chosen when editing
are added to the existing ones, and each one has its own remove button (with confirmation) on the
repair's page and its edit page. lists show a 96x72 cropped thumbnail of the first photo, the
repair's page shows an 800x600 version that links to the original. both sizes are named variants
in `app/models/repair.rb`.

the diagnosis is action text (trix editor), printed through action text's own sanitizer. rows in
lists show its first 60 characters as plain text.

the repairs index, the bike's page and the repair's page run the same number of queries however
many repairs or photos there are, preloaded in the controllers.

`bin/rails db:seed` can be run as many times as you like: it first removes the previous files and
rows, so every table ends with the same count.

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
