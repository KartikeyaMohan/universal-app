class Cast < ApplicationRecord

  has_many :movie_casts, dependent: :destroy
  has_many :movies, through: :movie_casts

  enum :cast_type, { actor: 'Actor', actress: 'Actress', director: 'Director', producer: 'Producer' }

  def self.image_key(filename)
    "cast/#{filename}"
  end
end