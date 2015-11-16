class Vote < Volt::Model
  own_by_user

  belongs_to :photo
  index [:photo_id, :user_id], unique: true

  field :up, Volt::Boolean, default: true
end
