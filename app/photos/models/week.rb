class Week < Volt::Model
  field :top_photo_url, String

  # The week number
  field :number, Fixnum, nil: false

  # The number of photos
  field :entry_count, Fixnum, nil: false
end
