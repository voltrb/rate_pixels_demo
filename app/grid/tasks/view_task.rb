class ViewTask < Volt::Task
  def view(ids)
    user = Volt.current_user.sync
    if user
      ids.each do |id|
        photo = store.photos.where(id: id).first.sync

        if photo
          if store.photo_views.where(photo_id: id, user_id: user.id).count.sync == 0
            photo.photo_views.create.then do
              # if created
              photo.view_count += 1
            end.fail do |err|
              puts "FAIL: #{err.inspect}"
            end
          end
        end
      end
    end

    nil
  end
end