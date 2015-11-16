# Photo info stores metadata associated with the photo
class PhotoInfo < Volt::Model
  belongs_to :photo

  index :photo_id, unique: true

  own_by_user
end
