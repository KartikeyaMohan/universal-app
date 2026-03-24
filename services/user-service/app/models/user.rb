class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  before_save { email.downcase! }

  def self.profile_image_key(user_email, filename)
    sanitized_email = user_email.downcase.gsub(/[@.]/, "_")
    "user/#{sanitized_email}/profile_image/#{filename}"
  end
end