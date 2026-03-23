class MovieDetail < ApplicationRecord
  belongs_to :movie

  def self.trailer_key(movie_title, filename)
    sanitized_title = movie_title.downcase.gsub(/\s+/, "_")
    "movie/#{sanitized_title}/trailer/#{filename}"
  end
end