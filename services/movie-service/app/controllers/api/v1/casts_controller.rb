module Api
  module V1
    class CastsController < BaseController
      def index
        cast = Cast.all
        json_response(cast)
      end

      def show
        cast = Cast.find(params[:id])
        json_response(cast)
      end

      def create
        cast = Cast.new(create_params.except(:image))

        if create_params[:image].present?
          filename = create_params[:image].original_filename
          key = Cast.image_key(filename)
          uploaded_key = S3Uploader.new.upload(
            file: create_params[:image],
            key: key
          )
          cast.image_key = uploaded_key
        end
        cast.save!

        json_response(cast)
      end

      def update
        cast = Cast.find(params[:id])

        if update_params[:image].present?
          uploader = S3Uploader.new
          uploader.delete(key: cast.image_key) if cast.image_key.present?

          filename = update_params[:image].original_filename
          key = Cast.image_key(filename)
          uploaded_key = uploader.upload(
            file: update_params[:image],
            key: key
          )
          cast.image_key = uploaded_key
        end
        cast.update!(update_params.except(:image))

        json_response(cast)
      end

      private

      def create_params
        params.require([:name, :cast_type])
        params.permit(:name, :image, :cast_type)
      end

      def update_params
        params.permit(:name, :image, :cast_type)
      end
    end
  end
end