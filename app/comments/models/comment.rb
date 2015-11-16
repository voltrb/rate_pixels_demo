require 'volt/helpers/time'

class Comment < Volt::Model
  own_by_user

  belongs_to :photo

  field :message, String
  field :created_at, VoltTime

  validate :message, length: 5

  before_create :set_time

  def set_time
    self.created_at ||= VoltTime.now
  end
end
