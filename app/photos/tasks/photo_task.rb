require 'image_resizer/lib/downloader'
require 'fastimage'
require 'exiftool'

class PhotoTask < Volt::Task
  include ImageResizer::Downloader

  # 10 minutes
  timeout(10 * 60)

  EXIF_KEYS = [:make, :model, :exposure_time, :f_number, :exposure_program, :iso, :shutter_speed_value, :aperture_value, :exposure_compensation, :max_aperture_value, :metering_mode, :light_source, :flash, :focal_length, :lens_info, :lens_model, :lens_id]

  def get_details(photo_id)
    photo = store.photos.where(id: photo_id).first.sync.buffer

    # use imageresizer to download the image
    file_path = download_cached(photo.file_url)

    # Get the image size
    photo.width, photo.height = FastImage.size(file_path)

    photo.save!.sync

    photo_info = store.photo_infos.buffer(photo_id: photo.id)

    # Grab the exif and put it in a PhotoInfo model
    exif = Exiftool.new(file_path)
    exif_hash = exif.to_hash.select {|k,v| EXIF_KEYS.include?(k) }

    exif_hash.each_pair do |key, value|
      photo_info.send(:"_#{key}=", value)
    end

    photo_info.save!

    nil
  end
end
