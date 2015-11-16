# Seeder
be volt runner app/photos/lib/seeder.rb

# Week closer
be volt runner app/photos/lib/week_closer_runner.rb

# Ranker
be volt runner app/photos/lib/ranker.rb

# Cache Images
VOLT_ENV=production be volt runner app/photos/lib/cache_images.rb

## clear rankers
(in the console)
store.rank_pages.all.reverse.each(&:destroy)

# Seed production


# Clear db
VOLT_ENV=production NO_MESSAGE_BUS=true bundle exec volt c
db = Volt.current_app.database.db
db.drop_table(*db.tables)


# TODO
redirect to login when voting and not logged in
when you vote it doesn’t update right
loggging in should redirect to popular

# TOFIX
- indexes aren't migrating?
- some volt issue with grid loading <:popover model="{{ something }}" />
  ^ I think maybe has to do with something being a promise already?
- needing to check count in view task
- stopped events (or prevent_default?) need to stop bubbling in volt also
- google maps not seeing Volt.config in a runner (causing load crash)


db = Volt.current_app.database.raw_db

db = Sequel.connect('postgres://poeerpgrwkggot:2NwtaGmXNuFY_j7w070qhCLbnc@ec2-107-21-221-107.compute-1.amazonaws.com:5432/dfhlc7vv943ha3', :max_connections => 1)
db[:votes].delete

.order(Sequel.lit('RANDOM()'))