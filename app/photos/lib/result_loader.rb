module ResultLoader

  def load_results(promise)
    promise.then do |results|
      self.page_count = results[:page_count]
      # Mark photos as having been voted
      voted_ups = {}
      voted_downs = {}
      results[:voted_ups].each do |id|
        voted_ups[id] = true
      end

      results[:voted_downs].each do |id|
        voted_downs[id] = true
      end

      store.photos.where(id: results[:id_list]).order(created_at: :asc).limit(per_page).all.then do |photos|
        photos.each do |photo|
          if voted_ups[photo.id]
            photo.voted_on = true
            photo.voted_up = true
            photo.voted_down = false
          end

          if voted_downs[photo.id]
            photo.voted_on = true
            photo.voted_up = false
            photo.voted_down = true
          end
        end

        photos
      end
    end
  end
end
