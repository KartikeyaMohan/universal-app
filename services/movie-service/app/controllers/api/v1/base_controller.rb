module Api
  module V1
    class BaseController < ApplicationController
      include Response

      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable

      private

      def not_found(error)
        json_error_response(error.message, :not_found)
      end

      def unprocessable(error)
        json_error_response(error.record.errors.full_messages, :unprocessable_content)
      end

    end
  end
end