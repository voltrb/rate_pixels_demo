# By default Volt generates this User model which inherits from Volt::User,
# you can rename this if you want.
class User < Volt::User
  # login_field is set to :email by default and can be changed to :username
  # in config/app.rb
  field login_field
  field :name, String
  field :account_level, Fixnum, default: 0
  field :bio, String
  field :location, String

  attachment :profile_pic, 'ratephotos_profile_' + Volt.env.to_s

  has_many :photos
  has_many :votes

  validate login_field, unique: true, length: 8
  validate :email, email: true

  permissions(:create, :update) do
    # The user shouldn't be able to upgrade their account level directly.
    deny :account_level unless account_level == 0
  end

  def profile_pic?
    profile_pic.present?
  end

  def cdn_profile_url(width, height)
    "/images/#{width}/#{height}/resize/#{profile_pic_url}"
  end
end
