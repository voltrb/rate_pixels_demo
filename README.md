# Volt app build for Rails Rumble, built with caution thrown to the wind

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
