class Notification < Volt::Model
  # from user
  own_by_user

  belongs_to :to_user, collection: :users, local_key: :to_user_id

  index :to_user_id

  field :created_at, VoltTime

  before_create :set_time

  def set_time
    unless RUBY_PLATFORM == 'opal'
      self.created_at ||= VoltTime.now
    end
  end


  def action
    action = case _type
    when 0
      'voted up your photo'
    when 1
      'commented on your photo'
    end
  end

  def photo
    store.photos.where(id: _photo_id).first
  end
end
