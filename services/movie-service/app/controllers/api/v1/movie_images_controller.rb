module Api
  module V1
    class MovieImagesController < BaseController
      def index
        movie_images = MovieImage.all
        json_response(movie_images)
      end

      def show
        movie_image = MovieImage.find(params[:id])
        json_response(movie_image)
      end

      def create
        movie_image = MovieImage.new(create_params)
        movie = Movie.find_by(id: create_params[:movie_id])
        return json_error_response(
          [{code: :not_found, message: 'Movie not found'}]
        ) unless movie.present?

        if create_params[:image].present?
          filename = create_params[image].original_filename
          key = MovieImage.image_key(movie.name, filename)
          uploaded_key = S3Uploader.new.upload(
            file: create_params[:image],
            key: key
          )
          movie_image.image_key = uploaded_key
        end
        movie_image.save!

        json_response(movie_image)
      end

      def update
        movie_image = MovieImage.find(params[:id])
        movie_id = update_params[:movie_id] || movie_image.movie_id
        movie = Movie.find_by(id: movie_id)
        return json_error_response(
          [{code: :not_found, message: 'Movie not found'}]
        ) unless movie.present?

        if update_params[:image].present?
          uploader = S3Uploader.new
          uploader.delete(key: movie_image.image_key) if movie_image.image_key.present?

          filename = update_params[:image].original_filename
          key = MovieImage.image_key(movie.name, filename)
          uploaded_key = uploader.upload(
            file: update_params[:image],
            key: key
          )
          movie_image.image_key = uploaded_key
        end
        movie_image.save!

        json_response(movie_image)
      end

      private

      def create_params
        params.permit(:movie_id, :image)
        params.require([:movie_id])
      end

      def update_params
        params.permit(:movie_id, :image)
      end
    end
  end
end