class TokenIssuer
  def self.issue(user)
    payload = { user_id: user.id, email: user.email }

    {
      auth_token: JwtAuth::JwtAuthenticator.encode_auth_token(payload.dup),
      refresh_token: JwtAuth::JwtAuthenticator.encode_refresh_token(payload.dup),
      expires_in: JwtAuth::JwtAuthenticator::AUTH_TOKEN_EXPIRY,
      token_type: "Bearer"
    }
  end

  def self.refresh(refresh_token)
    payload = JwtAuth::JwtAuthenticator.decode_refresh_token(refresh_token)
    user_payload = payload.slice("user_id", "email")
    {
      auth_token: JwtAuth::JwtAuthenticator.encode_auth_token(user_payload.dup),
      refresh_token: JwtAuth::JwtAuthenticator.encode_refresh_token(user_payload.dup),
      expires_in: JwtAuth::JwtAuthenticator::AUTH_TOKEN_EXPIRY,
      token_type: "Bearer"
    }
  end
end