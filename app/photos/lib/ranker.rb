# The ranker looks at all current photos and creates RakePages for each photo
# based on sorting them inverse of their order.
class Ranker
  PER_PAGE = Volt.config.public.per_page

  def initialize(week=0)
    @week = week
    # Do a direct Sequel query to create the rank pages

    @count = 0
    @page = 0
    @ids = []
    @previous_ranker_ids = db.from('rank_pages').all.map {|v| v[:id]}

    query = db.from('photos').select(:id).where(week: 0, ready: true)

    @page_count = (query.count / PER_PAGE).ceil

    # CLEAR: TODO, there's a sequel bug, so this has to happen here
    db[:rank_pages].delete

    # TODO: Add week number
    query.order(:view_count).each do |photo|
      @ids << photo[:id]
      @count += 1

      save if @count >= PER_PAGE
    end

    save
  end


  def db
    @db ||= Volt.current_app.database.raw_db
  end


  def save
    id = Volt.current_app.store.rank_pages.create(
      {
        week: @week,
        page: @page,
        id_list: @ids.join('|'),
        page_count: @page_count
      }
    ).sync.id

    puts "NEW RANKER: #{id}"

    @count = 0
    @page += 1
    @ids = []

  end
end

begin
  Ranker.new
rescue => e
  puts "ERR: #{e.inspect}"
end
