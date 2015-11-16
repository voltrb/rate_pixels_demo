class PhotoView < Volt::Model
  own_by_user

  belongs_to :photo
  index [:photo_id, :user_id], unique: true
end
