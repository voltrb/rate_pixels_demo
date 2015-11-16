class VoteTask < Volt::Task
  def vote(photo_id, up_or_down)
    user = Volt.current_user.sync

    if user
      vote = user.votes.where(photo_id: photo_id).first.sync

      if vote
        raise "Already voted"
      else
        photo = store.photos.where(id: photo_id).first.sync

        if up_or_down == 'up'
          photo.up_vote_count += 1

          # Create notificaiton for the vote
          to_user = photo.user.sync
          if to_user
            store.notifications.create(to_user: to_user, type: 0, photo_id: photo.id)
          end
        else
          photo.down_vote_count += 1
        end

        user.votes.create(photo_id: photo_id, up: up_or_down == :up)
      end
    end

    nil
  end
end
