module Photos
  class UploadsController < Volt::ModelController
    before_action :require_login
    reactive_accessor :already_uploaded

    def index

      self.model =       # Check if we already have a upload for this week
      Volt.current_user.photos.where(week: 0).first.then do |photo|
        if photo
          self.already_uploaded = true

          photo
        else
          store.photos.buffer.then do |photo|
            photo.on('uploaded_file') do
              # Save the Photo once its uploaded
              save
            end

            photo
          end
        end
      end
    end

    def index_ready
      %x(
        $('#upload-btn').click(function (e) {
          e.preventDefault();

          $('#files').trigger('click');
        });
      )
    end

    def details
      self.model = store.photos.where(id: params._id).first.buffer.then do |model|

        # setup google maps for selecting location
        @markers = Volt::Model.new._markers
        @markers << {address: "#{model.lat || 40.0},#{model.lng || -95.0}"}

        model.ready = true

        model
      end
    end

    def center
      "#{lat || 40.0},#{lng || -95.0}"
    end

    def map_click(lat, lng)
      @markers[0]._address = "#{lat},#{lng}"
      @markers[0]._content = ""

      self.lat = lat
      self.lng = lng
    end


    def save
      self.model.save!.then do
        # Get the details about the photo
        PhotoTask.get_details(model.id)
      end.then do
        redirect_to "/upload/details/#{model.id}"
      end.fail do |err|
        puts "ERR: #{err.to_s}"
        flash._errors << err.to_s
      end
    end

    def save_details
      self.model.save!.then do
        redirect_to "/profile/#{Volt.current_user_id}"
      end.fail do |err|
        flash._errors << err.to_s
      end
    end
  end
end
