class MovieCast < ApplicationRecord
  belongs_to :movie

  def self.image_key(movie_title, filename)
    sanitized_title = movie_title.downcase.gsub(/\s+/, "_")
    "movie/#{sanitized_title}/cast/#{filename}"
  end
end