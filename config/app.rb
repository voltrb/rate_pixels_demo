# app.rb is used to configure your app.  This code is only run on the server,
# then any config options in config.public are passed to the client as well.

Volt.configure do |config|
  # Setup your global app config here.

  #######################################
  # Basic App Info (stuff you should set)
  #######################################
  config.domain = 'ratepixels.com.com'
  config.scheme = Volt.env.production? ? 'https' : 'http' # http or https
  config.app_name = 'Ratepixels.com'
  config.mailer.from = 'Ratepixels.com <no-reply@ratepixels.com.com>'

  ############
  # App Secret
  ############
  # Your app secret is used for signing things like the user cookie so it can't
  # be tampered with.  A random value is generated on new projects that will work
  # without the need to customize.  Make sure this value doesn't leave your server.
  #
  # For added security we recommend moving the app secret into an environment.  You can
  # setup that like so:
  #
  # config.app_secret = ENV['APP_SECRET']
  #
  config.app_secret = 'b4g0HEZ7QCswXnpRb2uva2yP6oTGiIwNNTbPwgm9iHpcaHyXFoZ18sjLx8rCJQdPXdE'

  ###############
  # Log Filtering
  ###############
  # Data updates from the client come in via Tasks.  The task dispatcher logs all calls to tasks.
  # By default hashes in the arguments can be filtered based on keys.  So any hash with a key of
  # password will be filtered.  You can add more fields to filter below:
  config.filter_keys = [:password]

  ##########
  # Database
  ##########
  # Database config all start with db_ and can be set either in the config
  # file or with an environment variable (DB_NAME for example).

  # Default Sqlite Setup
  # config.db_driver = 'sqlite' # or 'postgres' or 'mysql'
  # config.db.database = "config/db/#{config.app_name}_#{Volt.env.to_s}.db"

  ryans = `hostname`.strip == 'Ryans-MacBook-Pro'
  config.public.ryans = ryans

  if ryans
    base_uri = 'postgres://ryanstout:@localhost:5432/'
  else
    base_uri = 'postgres://coreystout:@localhost:5432/'
  end

  config.db_driver = 'postgres'

  if Volt.env.production?
    if ENV['DATABASE_URL']
      config.db.uri = ENV['DATABASE_URL']
    else
      config.db.uri = "#{base_uri}rate_pixels_prod"
    end
  else
    config.db.uri = "#{base_uri}rate_pixels_dev"
  end

  if !config.public.ryans && Volt.env.production?
    # use redis in production
    config.message_bus.bus_name = 'redis'
  end

  config.resize_cache_time = 60*60*24*7 # 1 week

  config.public.per_page = 30

  # for postgres or mysql configuration, see the sequel options here:
  # http://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html#label-General+connection+options
  # Any options set on config.db will be passed to Sequel on connect.
  # Example (with uri):
  #
  # config.db.uri = 'postgres://ryanstout:@localhost:5432/blog_demo10'
  #
  # Example (with options)
  # config.db_driver = 'postgres'# or 'mysql'
  # config.db.database = "#{config.app_name}_#{Volt.env.to_s}"
  # config.db.host = 'mydatabase.com/'
  # config.db.user = 'my user'
  # config.db.password = 'some password'

  #####################
  # Compression options
  #####################
  # If you are not running behind something like nginx in production, you can
  # have rack deflate all files.
  # config.deflate = true

  #########################
  # Websocket configuration
  #########################
  # If you need to use a different domain or path for the websocket connection,
  # you can set it here.  Volt provides the socket connection url at /socket,
  # but if for example you are using a proxy server that doesn't support
  # websockets, you can point the websocket connection at the app server
  # directly.
  # config.public.websocket_url = '/socket'

  #######################
  # Public configurations
  #######################
  # Anything under config.public will be sent to the client as well as the server,
  # so be sure no private data ends up under public

  # Use username instead of email as the login
  # config.public.auth.use_username = true

  #####################
  # Compression Options
  #####################
  # Disable or enable css/js/image compression.  Default is to only run in production.
  # if Volt.env.production?
  #   config.compress_javascript = true
  #   config.compress_css        = true
  #   config.compress_images     = true
  # end

  ################
  # Mailer options
  ################
  # The volt-mailer gem uses pony (https://github.com/benprew/pony) to deliver e-mail.  Any
  # options you would pass to pony can be setup below.
  # NOTE: The from address is setup at the top

  # Normally pony uses /usr/sbin/sendmail if one is installed.  You can specify smtp below:
  # config.mailer.via = :smtp
  # config.mailer.via_options = {
  #   :address        => 'smtp.yourserver.com',
  #   :port           => '25',
  #   :user_name      => 'user',
  #   :password       => 'password',
  #   :authentication => :plain, # :plain, :login, :cram_md5, no auth by default
  #   :domain         => "localhost.localdomain" # the HELO domain provided by the client to the server
  # }

  #############
  # Message Bus
  #############
  # Volt provides a "Message Bus" out of the box.  The message bus provides
  # a pub/sub service between any volt instance (server, client, runner, etc..)
  # that share the same database.  The message bus can be used by app code.  It
  # is also used internally to push data to any listening clients.
  #
  # The default message bus (called "peer_to_peer") uses the database to sync
  # socket ip's/ports.
  # config.message_bus.bus_name = 'peer_to_peer'
  #
  # Encrypt message bus - messages on the message bus are encrypted by default
  # using rbnacl.

  # config.message_bus.disable_encryption = true

  #
  # ## MessageBus Server -- the message bus binds to a port and ip which the
  # other volt instances need to be able to connect to.  You can customize
  # the server below:
  #
  # Port range - you can specify a range of ports that an instance can bind the
  # message bus on.  You can specify a range, an array of Integers, or an array
  # of ranges.
  # config.message_bus.bind_port_ranges = (58000..61000)
  #
  # Bind Ip - specifies the ip address the message bus server should bind on.
  # config.message_bus.bind_ip = '127.0.0.1'

  #############
  # Concurrency
  #############
  # Volt provides a thread worker pool for incoming task requests (and all
  # database requests, since those use tasks to do their work.)  The following
  # lets you control the size of the worker pool.  Threads are only created as
  # needed, and are removed after a certain amount of inactivity.
  # config.min_worker_threads = 1
  # config.max_worker_threads = 10
  #
  # You can also specify the amount of time a Task should run for before it
  # timeout's.  Setting this to short can cause unexpected results, currently
  # we recomend it be at least 10 seconds.
  # config.worker_timeout = 60
  config.s3.key = ENV['S3_API_KEY']
  config.s3.secret = ENV['S3_SECRET_KEY']

  # Google maps
  config.public.google_maps_api_key = ENV['GOOGLE_MAPS_KEY']
  config.google_maps_skip_js_file = true

end
