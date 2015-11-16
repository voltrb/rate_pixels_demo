require 'volt/helpers/time'

class Photo < Volt::Model
  field :created_at, VoltTime
  attachment :file, 'ratepixels_photo_' + Volt.env.to_s
  field :up_vote_count, Fixnum, default: 0, nil: false
  field :down_vote_count, Fixnum, default: 0, nil: false
  field :height, Fixnum
  field :width, Fixnum
  field :title, String
  field :description, String
  field :tag_list, String
  field :lat, Float
  field :lng, Float
  field :ready, Volt::Boolean, default: false
  field :view_count, Fixnum, default: 0
  field :score, Float, default: 0.0

  # The week the photo went active
  field :week, Fixnum, default: 0

  # Is cached?
  field :c, Volt::Boolean, default: false

  index :week

  # Used on the client to show if the photo has been voted for
  reactive_accessor :voted_on, :voted_up, :voted_down

  own_by_user

  has_one :photo_info
  has_many :photo_views
  has_many :votes
  has_many :comments

  before_create :set_time

  def set_time
    unless RUBY_PLATFORM == 'opal'
      self.created_at ||= VoltTime.now
    end
  end

  validations do
    if ready
      validate :title, length: 5
    end
  end

  permissions(:update) do
    # User can't change the file url after create
    deny :file_url

    # don't set ready until the height is pulled in
    # TODO: check not working correctly
    # unless VOLT_ENV == 'opal'
    #   deny :ready unless height
    # end
  end

  DIMENSIONS = [
    [200,200],
    [400,400],
    [800,800],
    [1600,1600],
    [3200,3200]
    #original
  ]

  def loaded_sizes
    @loaded_sizes ||= {}
  end

  # returns the largest version of the image that is known to have been loaded
  # in this sessoin.  This is useful for creating a preview image before the
  # large version loads
  def file_url_largest_cached(width, height)
    # Find the index of the full size
    index = DIMENSIONS.find_index {|v| v[0] >= width && v[1] >= height }

    # Drop down one, and load only cached below the main
    width, height = DIMENSIONS[index-1] || [200,200]
    use_width, use_height = loaded_sizes.keys.sort.reverse.find {|v| v[0] <= width && v[1] <= height }

    if use_width
      file_url_at_least(use_width, use_height)
    else
      nil
    end
  end

  # Returns an image with at least the width/height.  This makes it so caches
  # happen at predictable sizes.
  def file_url_at_least(width, height)
    use_width, use_height = DIMENSIONS.find {|v| v[0] >= width && v[1] >= height }

    loaded_sizes[[use_width, use_height]] = true

    url = file_url

    self.class.for_size(url, use_width, use_height)
  end

  def self.for_size(url, use_width, use_height)
    if Volt.env.production?
      "https://d3gzyk9dvb18fw.cloudfront.net/images/#{use_width}/#{use_height}/resize/#{url}"
    else
      if Volt.config.public.ryans
        "https://d1dk9pgzzo8jz5.cloudfront.net/images/#{use_width}/#{use_height}/resize/#{url}"
      else
        "https://d18i8uzfivueh1.cloudfront.net/images/#{use_width}/#{use_height}/resize/#{url}"
      end
    end
  end

end
