class ApplicationController < ActionController::API
  include JwtAuth::Authenticatable
end
