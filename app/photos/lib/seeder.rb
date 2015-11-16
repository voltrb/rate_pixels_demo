require 'faker'
require 'photos/lib/week_closer'

# Populates the app with fake users and photos
class Seeder
  USER_COUNT = 130
  WEEK_COUNT = 5

  def initialize
    @photos = Dir["/Users/#{`whoami`.strip}/Desktop/demo_photos/*.jpeg"].shuffle

    users = []
    USER_COUNT.times do |index|
      puts "I: #{index}"
      # photo_url = upload_file(path)
      email = 'seeded_' + Faker::Internet.email
      password = Faker::Internet.password

      users << store.users.create(
        name: Faker::Name.name,
        email: email,
        password: password,
        bio: Faker::Hipster.paragraphs(3).join("\n\n"),
        location: Faker::Address.city
      ).sync

      store.seed_accounts.create(
        email: email,
        password: password
      )
    end

    WEEK_COUNT.times do
      # Loop through each user and create a single photo for a week
      add_week(users)

      # Close the week
      WeekCloser.new
    end


    # Run one more time for popular
    # Loop through each user and create a single photo for a week
    add_week(users)

  end

  def add_week(users)
    puts "ADD WEEK: #{users.inspect}"
    threads = []
    users.each do |user|
      threads << Thread.new do
        begin
          add_for_week(user)
        rescue => e
          puts "ERROR: #{e.inspect}"
        end
      end
    end

    threads.each(&:join)
  end

  def add_for_week(user)
    add_photo(user)
    add_votes(user)
  end

  def add_photo(user)
    file = @photos.pop
    puts "Upload for #{user.name}"
    create_photo(user, file, 0)
  end

  def create_photo(user, path, week)
    photo_url = upload_file(path)

    if week == 0
      score = 0.0
    else
      score = rand(2000000) / 1000.0
    end

    Volt.as_user(user) do
      photo = store.photos.create(
        file_url: photo_url,
        ready: true,
        title: Faker::Hipster.sentence(1),
        description: Faker::Hipster.paragraphs(3).join("\n\n"),
        tag_list: Faker::Hipster.words(4).join(", "),
        week: week
      ).sync

      PhotoTask.get_details(photo.id).sync
    end
  rescue => e
    # Ignore
  end

  def upload_file(path)
    bucket_name = Photo.new.file_bucket
    extname = File.extname(path)
    filename = "#{SecureRandom.uuid}#{extname}"
    upload_key = Pathname.new(filename).to_s

    creds = Aws::Credentials.new(Volt.config.s3.key, Volt.config.s3.secret)
    s3 = Aws::S3::Resource.new(region: 'us-east-1', credentials: creds)
    bucket = s3.bucket(bucket_name)

    obj = bucket.object(upload_key)

    obj.upload_file(path, {acl: 'public-read'})

    obj.public_url
  end

  # Create random votes for a user
  def add_votes(user)
    # select 20 random photos in week 0

    ids = db[:photos].select(:id).where(ready: true, week: 0).order(Sequel.lit('RANDOM()')).limit(20).all.map{|p| p[:id] }

    ids.each do |id|
      Volt.as_user(user) do
        photo = store.photos.where(id: id).first.sync

        up = rand(2) == 0

        if up
          photo.up_vote_count += 1
        else
          photo.down_vote_count += 1
        end

        store.votes.create(photo_id: id, up: up).sync
      end
    end
  end

  def db
    @db ||= Volt.current_app.database.raw_db
  end

  def store
    Volt.current_app.store
  end
end

Seeder.new
