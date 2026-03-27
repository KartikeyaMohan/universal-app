module Api
  module V1
    class LocationController < BaseController
      def index
        locations = Location.all
        data = locations.map { |location| location_hash(location) }
        json_response(data)
      end

      def show
        location = Location.find(params[:id])
        json_response(location_hash(location))
      end

      def create
        location = Location.new(create_params)
        location.user_id = current_user_id
        if location.save!
          json_response('Location added successfully')
        end
      end

      def update
        location = Location.find(params[:id])
        update_params[:user_id] = current_user_id
        if location.update!(update_params)
          json_response('Location updated successfully')
        end
      end

      private

      def location_hash(location)
        {
          id: location.id,
          latitude: location.latitude,
          longitude: location.longitude,
          accuracy: location.accuracy
        }
      end

      def create_params
        params.require(:latitude, :longitude)
        params.permit(:latitude, :longitude, :accuracy)
      end

      def update_params
        params.permit(:latitude, :longitude, :accuracy)
      end
    end
  end
end