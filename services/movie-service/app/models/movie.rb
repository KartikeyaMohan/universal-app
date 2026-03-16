class Movie < ApplicationRecord
  has_one :movie_detail
  has_many :movie_casts
  has_many :movie_images

  def self.hero_image_key(movie_title, filename)
    sanitized_title = movie_title.downcase.gsub(/\s+/, "_")
    "movie/#{sanitized_title}/hero_image/#{filename}"
  end
end