# Queries from the client to load in various views
class PhotoLoadTask < Volt::Task
  def db
    @db ||= Volt.current_app.database.raw_db
  end

  def popular(page)

    rank_page = store.rank_pages.where(week: 0, page: page).first.sync

    if rank_page
      ids = rank_page.id_list.split("|")

      with_votes(ids, rank_page.page_count)
    else
      nil
    end
  end

  def search(query, page)
    raise "Invalid Query" unless query =~ /^[A-Za-z0-9_\-]+$/
    query.gsub!('"\'', '')
    query = db.from(:photos).where(Sequel.ilike(:tag_list, "%#{query}%")).select(:id).where(ready: true)

    count = query.count
    ids = query.reverse_order(:view_count).all.map {|v| v[:id] }

    count = (count / Volt.config.public.per_page).ceil
    with_votes(ids, count)
  end

  def best_of_week(week, page)
    week = week.to_i
    per_page = Volt.config.public.per_page
    offset = page * per_page
    query = db.from(:photos).where(week: week, ready: true).select(:id).limit(per_page).offset(offset)
    count = (query.count / per_page).ceil
    ids = query.order(Sequel.desc(:score)).all.map {|p| p[:id]}
    with_votes(ids, count)
  end

  def user_photos(user_id)
    ids = db.from(:photos).where(ready: true, user_id: user_id).all.map {|v| v[:id] }
    with_votes(ids, 1)
  end

  private

  def with_votes(ids, count)
    voted_ups = []
    voted_downs = []
    if (user_id = Volt.current_user_id)
      db.from(:votes).where(user_id: user_id, photo_id: ids).select(:photo_id, :up).all.each do |p|
        if p[:up]
          voted_ups << p[:photo_id]
        else
          voted_downs << p[:photo_id]
        end
      end
    end

    # Pull in all ids that we have voted for
    {id_list: ids, voted_ups: voted_ups, voted_downs: voted_downs, page_count: count}
  end
end
