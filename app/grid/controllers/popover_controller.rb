module Grid
  class PopoverController < Volt::ModelController
    def index_ready
      # Track view
      ViewTask.view([photo.id]).fail {|e| puts e.inspect }
    end

    def close_zoom
      params._photo_id = nil
    end

    def exposure
      _exposure_time ? "#{_exposure_time}s" : nil
    end

    def f_number
      _f_number ? "f/#{_f_number}" : nil
    end

    def focal_length
      _focal_length ? _focal_length.to_s.gsub(' ', '') : nil
    end

    def iso
      _iso ? "#{_iso}iso" : nil
    end

    def settings
      [exposure, f_number, focal_length, iso].compact.join('   ')
    end

    def center
      Promise.when(lat, lng).then do |lat, lng|
        "#{lat},#{lng}"
      end
    end

    def marker
      center.then do |center|
        [Volt::Model.new({address: center, content: ''})]
      end
    end

    def vote(direction)
      Volt.current_user.then do |user|
        if user
          model.voted_on = true
          model.voted_up = (direction == 'up')
          model.voted_down = (direction != 'up')

          VoteTask.vote(id, direction).fail do |err|
            flash._errors << err.to_s
          end
        else
          flash._notices << 'Please login or signup to vote on photos'
          redirect_to '/login'
        end
      end
    end

    def voted_on
      model.voted_on || Volt.current_user.votes.where(photo_id: params._id).count.then {|c| c > 0 }
    end

    def destroy
      model.then do |photo|
        photo.destroy
        params._photo_id = nil
      end
    end

    def show_location
      controller._show_location = true
    end

    def show_location?
      controller._show_location
    end

    def tag_list
      model.tag_list.split(',')
    end

  end
end
