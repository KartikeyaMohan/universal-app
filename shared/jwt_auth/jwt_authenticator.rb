require "jwt"

module JwtAuth
  class JwtAuthenticator
    ALGORITHM = "HS256"
    AUTH_TOKEN_EXPIRY = 30 * 60 #30 minutes
    REFRESH_TOKEN_EXPIRY = 7 * 24 * 3600 #7 days

    def self.encode_auth_token(payload)
      payload[:exp]  = Time.now.to_i + AUTH_TOKEN_EXPIRY
      payload[:type] = "auth"
      JWT.encode(payload, jwt_auth_secret, ALGORITHM)
    end

    def self.decode_auth_token(token)
      decoded = JWT.decode(token, jwt_auth_secret, true, algorithm: ALGORITHM)
      payload = HashWithIndifferentAccess.new(decoded[0])

      raise JwtAuth::Errors::InvalidToken if payload[:type] != "auth"

      payload
    rescue JWT::ExpiredSignature
      raise JwtAuth::Errors::TokenExpired
    rescue JWT::DecodeError
      raise JwtAuth::Errors::InvalidToken
    end

    def self.encode_refresh_token(payload)
      payload[:exp]  = Time.now.to_i + REFRESH_TOKEN_EXPIRY
      payload[:type] = "refresh"
      JWT.encode(payload, jwt_refresh_secret, ALGORITHM)
    end

    def self.decode_refresh_token(token)
      decoded = JWT.decode(token, jwt_refresh_secret, true, algorithm: ALGORITHM)
      payload = HashWithIndifferentAccess.new(decoded[0])

      raise JwtAuth::Errors::InvalidToken if payload[:type] != "refresh"

      payload
    rescue JWT::ExpiredSignature
      raise JwtAuth::Errors::RefreshTokenExpired
    rescue JWT::DecodeError
      raise JwtAuth::Errors::InvalidToken
    end

    def self.jwt_auth_secret
      ENV["JWT_AUTH_SECRET"] or raise "JWT_AUTH_SECRET environment variable not set"
    end

    def self.jwt_refresh_secret
      ENV["JWT_REFRESH_SECRET"] or raise "JWT_REFRESH_SECRET environment variable not set"
    end
  end

  module Errors
    class TokenExpired         < StandardError; end
    class InvalidToken         < StandardError; end
    class Unauthorized         < StandardError; end
    class RefreshTokenExpired  < StandardError; end
    class InvalidRefreshToken  < StandardError; end
  end
end