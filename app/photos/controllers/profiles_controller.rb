require 'photos/lib/result_loader'

module Photos
  class ProfilesController < Volt::ModelController
    include ResultLoader

    reactive_accessor :page_count

    def per_page
      1000
    end

    def index
      self.model = store.users.where(id: params._id).first

      # @params_watcher = proc do
      #   params._id

      #   @params_watcher.remove if @params_watcher

      #   index
      # end.watch!
    end

    def before_index_remove
      @params_watcher.remove if @params_watcher
    end

    def has_user_photos
      store.users.where(id: params._id).first.photos.where(ready: true).count.then {|c| c > 0 }
    end

    def user_photos
      load_results(PhotoLoadTask.user_photos(params._id)).then do |photos|
        photos
      end.fail do |err|
        puts "ERR: #{err.inspect}"
      end
    end
  end
end
