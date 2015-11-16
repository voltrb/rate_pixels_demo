module Comments
  class MainController < Volt::ModelController
    reactive_accessor :new_comment

    def index
      # Add code for when the index view is loaded
    end

    def new
      self.model = store.comments.buffer

      @new_watch = proc do
        params._photo_id
        self.model.message = ''
      end.watch!
    end

    def before_new_remove
      @new_watch.stop if @new_watch
    end

    def add_comment
      model.photo_id = params._photo_id
      model.save!.then do
        store.notifications.create({type: 1, to_user_id: model.user_id, photo_id: model.photo_id})
      end.then do
        before_new_remove
        new

        flash._notices << "Comment Added."
      end.fail do |err|
        puts "ERR: #{err.inspect}"
      end
    end
  end
end