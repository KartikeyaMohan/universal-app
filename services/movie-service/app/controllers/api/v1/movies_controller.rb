module Api
  module V1
    class MoviesController < BaseController
      def index
        movies = Movie
                  .page(index_params[:page] || 1)
                  .per(index_params[:limit] || 10)
        data = movies.map { |movie| {
          name: movie.name,
          rating: movie.rating,
          hero_image_url: movie.hero_image_key.present? ? S3Uploader.new.presigned_url(key: movie.hero_image_key) : nil
        } }
        json_response({
          data: ,
          meta: {
            current_page: movies.current_page,
            next_page: movies.next_page,
            prev_page: movies.prev_page,
            total_pages: movies.total_pages,
            total_count: movies.total_count
          }
        })
      end

      def show
        movie = Movie.find(params[:id])
        s3 = S3Uploader.new
        response = {
          name: movie.name,
          rating: movie.rating,
          hero_image_url: movie.hero_image_key.present? ? s3.presigned_url(key: movie.hero_image_key) : nil
        }
        movie_detail = movie.movie_detail
        response.merge!({
          description: movie_detail.description,
          trailer_url: movie_detail.trailer_key.present? ? s3.presigned_url(key: movie_detail.trailer_key) : nil
        }) if movie_detail.present?

        casts = []
        movie.casts.each do |cast|
          image_url = cast.image_key.present? ? s3.presigned_url(key: cast.image_key) : nil
          casts << { name: cast.name, image_url: image_url, cast_type: cast.cast_type }
        end

        response.merge!({casts: })

        json_response(response)
      end

      def create
        movie = Movie.new(create_params.except(:hero_image))
        if create_params[:hero_image].present?
          filename = create_params[:hero_image].original_filename
          key = Movie.hero_image_key(movie.name, filename)
          uploaded_key = S3Uploader.new.upload(
            file: create_params[:hero_image],
            key: key
          )
          movie.hero_image_key = uploaded_key
        end
        movie.save!

        json_response(movie)
      end

      def update
        movie = Movie.find(params[:id])
        if update_params[:hero_image].present?
          uploader = S3Uploader.new
          uploader.delete(key: movie.hero_image_key) if movie.hero_image_key.present?

          filename = update_params[:hero_image].original_filename
          key = Movie.hero_image_key(movie.name, filename)
          uploaded_key = uploader.upload(
            file: update_params[:hero_image],
            key: key
          )
          movie.hero_image_key = uploaded_key
        end

        movie.update!(update_params.except(:hero_image))
        json_response(movie)
      end

      private

      def index_params
        params.permit(:page, :limit)
      end 

      def create_params
        params.require(:name)
        params.permit(:name, :hero_image, :rating)
      end

      def update_params
        params.permit(:name, :hero_image, :rating)
      end
    end
  end
end