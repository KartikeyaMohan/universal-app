require "/shared/jwt_auth/jwt_authenticator"

module JwtAuth
  module Authenticatable
    extend ActiveSupport::Concern

    included do
      before_action :authenticate_request!
    end

    private

    def authenticate_request!
      token = extract_token
      raise JwtAuth::Errors::Unauthorized, "Token missing" unless token

      @current_user_payload = JwtAuth::JwtAuthenticator.decode_auth_token(token)
    rescue JwtAuth::Errors::TokenExpired
      render json: { error: "Token has expired" }, status: :unauthorized
    rescue JwtAuth::Errors::InvalidToken
      render json: { error: "Invalid token" }, status: :unauthorized
    rescue JwtAuth::Errors::Unauthorized => e
      render json: { error: e.message }, status: :unauthorized
    end

    def current_user_id
      @current_user_payload&.dig("user_id")
    end

    def current_user_email
      @current_user_payload&.dig("email")
    end

    def extract_token
      header = request.headers["Authorization"]
      header&.split(" ")&.last   # handles "Bearer <token>"
    end
  end
end