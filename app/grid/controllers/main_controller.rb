module Grid
  class ScaledPhoto < Struct.new(:width, :height, :photo)
  end

  class SelectedPhoto < Struct.new(:width, :height, :photo_url, :preview_url, :photo)
  end
  class MainController < Volt::ModelController
    # The current photo (passed in directly instead of loading new)
    reactive_accessor :cur_photo

    def index
      # Setup listener for window resize
      resized = -> { window_resize}
      `$(window).on('resize.main', resized);`
      window_resize
    end

    # Track views
    def index_ready
      track_views

      key_handler = proc {|event| handle_keypress(event) }
      `$(document).on('keydown.main', key_handler);`
    end

    def before_index_remove
      interval = @interval
      `clearInterval(interval)` if interval
      `$(document).on('keydown.main');`
      `$(window).off('resize.main');`
    end

    def handle_keypress(event)
      which = `event.which`

      if which == 37
        # left
        previous_photo
      elsif which == 39
        # right
        next_photo
      end
    end

    def current_photo
      if (photo_id = params._photo_id)
        cur_photo || store.photos.where(id: photo_id).first
      else
        nil
      end
    end

    def next_photo(event)
      change_photo(1)
    end

    def previous_photo(event)
      change_photo(-1)
    end

    def change_photo(move_by)
      index = current_index
      new_photo = nil
      if index
        new_pos = index + move_by
        if new_pos >= 0
          new_photo = model[new_pos]
        end

        new_photo.then do |new_photo|
          if new_photo
            params._photo_id = new_photo.id
            self.cur_photo = new_photo
          end
        end
      end
    end


    def current_index
      params._photo_id # depend before promise
      model.find_index {|p| p.id == params._photo_id }
    end

    # Return the selected photo with some extra data to render a preview quiclky
    # from the grid.
    def selected_photo
      photo = current_photo

      photo.then do |photo|
        if photo
          # Scale the photo to fit into the window
          window_width = `$(window).width()`
          window_height = `$(window).height() - 100`

          width_ratio = window_width / photo.width.to_f
          height_ratio = window_height / photo.height.to_f

          scale_factor = [width_ratio, height_ratio].min

          width = (photo.width * scale_factor).round
          height = (photo.height * scale_factor).round

          preview_url = photo.file_url_largest_cached(width, height)
          url = photo.file_url_at_least(width, height)

          SelectedPhoto.new(width, height, url, preview_url, photo)
        end
      end
    end


    def zoom(photo, event)
      self.cur_photo = photo.photo
      params._photo_id = photo.photo.id
    end

    def window_resize
      if @grid_dep
        if `$('.photo-grid').get(0)`
          grid_width = `$('.photo-grid').width()`

          if grid_width && @last_grid_width && @last_grid_width != grid_width
            # Grid width changed
            @grid_dep.changed!
          end
        end
      end
    end

    def grid_width
      @grid_dep = Volt::Dependency.new
      @grid_dep.depend
      grid_width = `$('.photo-grid').width()`
      @last_grid_width = grid_width
      grid_width
    end


    # Scaled photos returns ScaledPhoto instances, which have the height, width,
    # and the photo.  It changes the height of photos to fit into a grid.
    def scaled_photos
      # How big is the area where we're showing phtoos
      row_width = grid_width

      scaled_photos = []

      # resolve the photos promise (if a promise)
      aspect_ratios = []
      photos = model.reject do |photo|
        if photo.height
          aspect_ratios << ((photo.width / photo.height) * 100).round
          false # keep
        else
          true # reject
        end
      end

      scaled_widths = summed_widths(photos)
      # Sum the width for the photos
      number_of_rows = (scaled_widths / row_width).round
      number_of_rows = [(number_of_rows / 2).round, 1].max

      partitions = `partition(aspect_ratios, number_of_rows)`

      index = 0

      partitions.map do |row|
        summed_ratios = row.sum
        row.each do |ratio|
          photo = photos[index]

          # the percent of the rows width this photo should take up
          percent_width = ratio / summed_ratios
          width = percent_width * row_width
          height = width / (ratio / 100.0)

          index += 1
          scaled_photos << ScaledPhoto.new(width.floor, height.floor, photo)
        end
      end

      scaled_photos
    end

    def track_views
      ids = model.map(&:id)

      ViewTask.view(ids).fail {|e| puts e.inspect }
    end

    def vote(id, direction, event)
      event.stop!
      event.prevent_default!

      Volt.current_user.then do |user|
        if user
          model.each do |photo|
            if photo.id == id
              photo.voted_on = true
              break
            end
          end

          VoteTask.vote(id, direction).fail do |err|
            flash._errors << err.to_s
          end
        else
          flash._notices << 'Please login or signup to vote on photos'
          redirect_to '/login'
        end
      end
    end

    private
    def summed_widths(photos, ideal_height=`$(window).height() / 1.8`)
      model.map do |photo|
        height = photo.height
        width = photo.width
        ratio = width / height

        ratio * ideal_height
      end.sum
    end

  end
end
