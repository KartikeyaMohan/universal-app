module Api
  module V1
    class UsersController < BaseController

      def profile
        user = User.find(current_user_id)
        json_response(hash_user(user))
      rescue
        json_error_response([code: :not_found, message: 'User not found'], :not_found)
      end

      def update_profile
        user = User.find(current_user_id)
        return json_error_response([code: :not_found, message: 'User not found'], :not_found) unless user.present?

        if update_params[:profile_image].present?
          filename = update_params[:profile_image].original_filename
          key = User.profile_image_key(user.email, filename)
          user.profile_image_key = S3Uploader.new.upload(
            file: update_params[:profile_image],
            key:  key
          )
        end
        user.name = update_params[:name] || user.name

        user.save!
        json_response({message: 'Profile updated successfully'})
      end

      private

      def hash_user(user)
        {
          id: user.id,
          name: user.name,
          email: user.email,
          profile_image_url: user.profile_image_key.present? ?
            S3Uploader.new.presigned_url(key: user.profile_image_key) : nil,
        }
      end

      def update_params
        params.permit(:name, :profile_image)
      end
    end
  end
end