module Api
  module V1
    class MovieCastsController < BaseController
      def index
        movie_cast = MovieCast.all
        json_response(movie_cast)
      end

      def show
        movie_cast = MovieCast.find(params[:id])
        json_response(movie_cast)
      end

      def create
        movie_cast = MovieCast.new(create_params)
        movie = Movie.find_by(id: create_params[:movie_id])
        return json_error_response(
          [{code: :not_found, message: 'Movie not found'}]
        ) unless movie.present?

        if create_params[:image].present?
          filename = create_params[image].original_filename
          key = MovieCast.image_key(movie.name, filename)
          uploaded_key = S3Uploader.new.upload(
            file: create_params[:image],
            key: key
          )
          movie_cast.image_key = uploaded_key
        end
        movie_cast.save!

        json_response(movie_cast)
      end

      def update
        movie_cast = MovieCast.find(params[:id])
        movie_id = update_params[:movie_id] || movie_cast.movie_id
        movie = Movie.find_by(id: movie_id)
        return json_error_response(
          [{code: :not_found, message: 'Movie not found'}]
        ) unless movie.present?

        if update_params[:image].present?
          uploader = S3Uploader.new
          uploader.delete(key: movie_cast.image_key) if movie_cast.image_key.present?

          filename = update_params[:image].original_filename
          key = MovieCast.image_key(movie.name, filename)
          uploaded_key = uploader.upload(
            file: update_params[:image],
            key: key
          )
          movie_cast.image_key = uploaded_key
        end
        movie_cast.save!

        json_response(movie_cast)
      end

      private

      def create_params
        params.permit(:movie_id, :name, :image)
        params.require([:movie_id])
      end

      def update_params
        params.permit(:movie_id, :name, :image)
      end
    end
  end
end