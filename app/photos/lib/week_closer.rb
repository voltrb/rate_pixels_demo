# Closes out a week
class WeekCloser
  def initialize
    # Inc the week number
    week_number = Volt.current_app.properties[:week_num].to_i

    week_number += 1
    Volt.current_app.properties[:week_num] = week_number.to_s

    puts "CLOSE OUT #{week_number}"

    this_week = db[:photos].where(ready: true, week: 0)

    entry_count = this_week.count

    top_photo_url = this_week.select(:file_url).order(Sequel.desc(:score)).first[:file_url]

    # Get the ids for each photo in the week and compute the score
    ids = this_week.select(:id).all.map {|p| p[:id] }

    ids.each do |id|
      compute_score(id)
    end

    # Set the week on all photos
    db[:photos].where(ready: true, week: 0).update(week: week_number)

    store.weeks.create(
      top_photo_url: top_photo_url,
      number: week_number,
      entry_count: entry_count
    ).sync
  end

  # TODO: make this better
  def compute_score(photo_id)
    photo = db[:photos].where(id: photo_id)
    score = photo.first[:up_vote_count] - photo.first[:down_vote_count]

    photo.update(score: score.to_f)
  end

  def store
    Volt.current_app.store
  end

  def db
    @db ||= Volt.current_app.database.raw_db
  end
end