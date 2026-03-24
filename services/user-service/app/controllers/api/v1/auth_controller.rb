module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_request!, only: [:register, :login, :refresh]

      def register
        user = User.new(register_params.except(:profile_image))

        if params[:profile_image].present?
          filename = params[:profile_image].original_filename
          key = User.profile_image_key(user.email, filename)
          user.profile_image_key = S3Uploader.new.upload(
            file: params[:profile_image],
            key:  key
          )
        end

        user.save!
        tokens = TokenIssuer.issue(user)

        json_response({
          id: user.id,
          tokens: 
        })
      rescue ActiveRecord::RecordInvalid => e
        json_error_response([code: :unprocessable_entity, message: e.record.errors.full_messages]) 
      end

      def login
        user = User.find_by(email: params[:email]&.downcase)

        if user&.authenticate(params[:password])
          tokens = TokenIssuer.issue(user)
          return json_response({
            id: user.id,
            tokens: 
          })
        else
          json_error_response([code: :unauthorized, message: 'Invalid email or password'], :unauthorized)
        end
      end

      def refresh
        tokens = TokenIssuer.refresh(params[:refresh_token])
        json_response({
          tokens: 
        })

      rescue JwtAuth::Errors::RefreshTokenExpired
        json_error_response([code: :unauthorized, message: 'Session expired, please login again'], :unauthorized)
      rescue JwtAuth::Errors::InvalidToken
        json_error_response([code: :unauthorized, message: 'Session expired, please login again'], :unauthorized)
      end

      private

      def register_params
        params.permit(:name, :email, :password, :password_confirmation, :profile_image)
      end
    end
  end
end