module Api
  module V1
    class MovieDetailsController < BaseController
      def index
        movie_details = MovieDetail.all
        json_response(movie_details)
      end

      def show
        movie_detail = MovieDetail.find(params[:id])
        response = movie_detail_with_url(movie_detail)
        json_response(response)
      end

      def create
        movie_detail = MovieDetail.new(create_params.except(:trailer))
        movie = Movie.find_by(id: create_params[:movie_id])
        return json_error_response(
          [{code: :not_found, message: 'Movie not found'}]
        ) unless movie.present?

        if create_params[:trailer].present?
          filename = create_params[:trailer].original_filename
          key = MovieDetail.trailer_key(movie.name, filename)
          uploaded_key = S3Uploader.new.upload(
            file: create_params[:trailer],
            key: key
          )
          movie_detail.trailer_key = uploaded_key
        end
        movie_detail.save!

        json_response(movie_detail)
      end

      def update
        movie_detail = MovieDetail.find(params[:id])
        movie_id = update_params[:movie_id] || movie_detail.movie_id
        movie = Movie.find_by(id: movie_id)
        return json_error_response(
          [{code: :not_found, message: 'Movie not found'}]
        ) unless movie.present?

        if update_params[:trailer].present?
          uploader = S3Uploader.new
          uploader.delete(key: movie_detail.trailer_key) if movie_detail.trailer_key.present?

          filename = update_params[:trailer].original_filename
          key = MovieDetail.trailer_key(movie.name, filename)
          uploaded_key = uploader.upload(
            file: update_params[:trailer],
            key: key
          )
          movie_detail.trailer_key = uploaded_key
        end
        movie_detail.save!

        json_response(movie_detail)
      end

      private

      def create_params
        params.require(:movie_id)
        params.permit(:movie_id, :trailer, :description)
      end

      def update_params
        params.permit(:movie_id, :trailer, :description)
      end

      def movie_detail_with_url(movie_detail)
        movie_detail.as_json.merge(
          trailer_url: movie_detail.trailer_key.present? ?
            S3Uploader.new.presigned_url(key: movie_detail.trailer_key) : nil
        )
      end
    end
  end
end