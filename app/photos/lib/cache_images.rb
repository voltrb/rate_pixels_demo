require 'open-uri'
require 'thread'

class CacheImages
  WORKER_COUNT = 5
  def initialize
    @queue = SizedQueue.new(WORKER_COUNT * 2)
    @count = 0
    @count_mutex = Mutex.new
    @cached_photos = File.read('tmp/cached_photos.txt').split("\n").map {|k| [k, true] }.to_h

    WORKER_COUNT.times do
      run_worker
    end

    # loop do
      photos = store.photos.limit(1000).all.sync

      # break if photos.size == 0
      photos.each do |photo|
        unless @cached_photos[photo.id]
          @queue.push(photo)
        end
      end
    # end

    WORKER_COUNT.times do
      @queue << :done
    end
  end

  def run_worker
    Thread.new do
      loop do
        photo = @queue.pop

        break if photo == :done

        Photo::DIMENSIONS.each do |w,h|
          puts "Download for #{photo.id}"
          url = Photo.for_size(photo.file_url, w, h)

          open(url) {|f| f.read }

          nil
        end

        # photo_buf = photo.buffer
        # photo_buf.c = true
        # photo_buf.save!.sync

        @count_mutex.synchronize do
          File.open('tmp/cached_photos.txt', 'a') {|f| f.write(photo.id + "\n")}
          @count += 1
        end

        puts "COUNT: #{@count}"
      end
    end
  end

  def store
    Volt.current_app.store
  end
end

CacheImages.new