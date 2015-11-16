source 'https://rubygems.org'

ruby "2.2.0"

# gem 'volt', github: 'voltrb/volt', branch: 'postgres4'
gem 'volt', path: '/Users/ryanstout/Sites/volt/volt'

# volt uses mongo as the default data store.
gem 'volt-sql', '~> 0.0.1'
# gem 'volt-sql', path: '/Users/ryanstout/Sites/volt/apps/volt-sql'

# Choose the database drivers
# sqlite (default, mostly for dev)
# gem 'sqlite3'

# Postgres
gem 'pg', '~> 0.18.2'
gem 'pg_json', '~> 0.1.29'

# Mysql
# gem 'mysql2'

gem 'volt-fields'

gem 'volt-materialize', github: 'ryanstout/volt-materialize'
# gem 'volt-materialize-fields'
# gem 'volt-materialize-notices'

gem 'volt-s3_uploader'
gem 'volt-image_resizer'
gem 'volt-pagination'
gem 'chronic'

gem 'volt-google_maps', path: '/Users/ryanstout/Sites/volt/apps/volt-google_maps'
gem 'fastimage'
gem 'exiftool_vendored'

gem 'volt-redis_message_bus'

gem 'faker', require: false, git: 'https://github.com/stympy/faker.git'

# # User templates for login, signup, and logout menu.
# gem 'volt-user_templates', '~> 0.5.1'

# Add ability to send e-mail from apps.
gem 'volt-mailer', '~> 0.1.1'

group :development do
  # browser_irb is optional, gives you an irb like terminal on the client
  # (hit ESC) to activate.
  gem 'volt-browser_irb'
end

# Use rbnacl for message bus encrpytion
# (optional, if you don't need encryption, disable in app.rb and remove)
#
# Message Bus encryption is not supported on Windows at the moment.
platform :ruby, :jruby do
  gem 'rbnacl', require: false
  gem 'rbnacl-libsodium', require: false
end

group :test do
  # Testing dependencies
  gem 'rspec', '~> 3.2.0'
  gem 'opal-rspec', '~> 0.4.2'
  gem 'capybara', '~> 2.4.4'
  gem 'selenium-webdriver', '~> 2.47.1'
  gem 'chromedriver-helper', '~> 1.0.0'
  gem 'poltergeist', '~> 1.6.0'
end

# Server for MRI
platform :mri, :mingw, :x64_mingw do
  # The implementation of ReadWriteLock in Volt uses concurrent ruby and ext helps performance.
  gem 'concurrent-ruby-ext', '~> 0.8.0'

  # Thin is the default volt server, Puma is also supported
  gem 'thin', '~> 1.6.0'
end

group :production do
  # Asset compilation gems, they will be required when needed.
  gem 'csso-rails', '~> 0.3.4', require: false
  gem 'uglifier', '>= 2.4.0', require: false

  # Image compression gem for precompiling assets
  gem 'image_optim'

  # Provides precompiled binaries for image compression
  gem 'image_optim_pack'
end
