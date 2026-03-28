module Api
  module V1
    class LocationsController < BaseController
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
        if create_params[:date].present? && create_params[:time].present?
          location.captured_at = Time.zone.strptime("#{create_params[:date]} #{create_params[:time]}", "%Y-%m-%d %H:%M")
        end
        if location.save!
          return json_response({ message: 'Location added successfully' })
        end
        json_error_response([{code: :create_failure, message: 'Unable to create location'}])
      end

      def update
        location = Location.find(params[:id])
        update_params[:user_id] = current_user_id
        if location.update!(update_params)
          return json_response({ message: 'Location updated successfully' })
        end
        json_error_response([{code: :update_failure, message: 'Unable to update location'}])
      end

      def bulk_create
        list = bulk_create_params[:list]
        user_id = current_user_id
        return json_error_response([{code: :not_found, messsage: 'No user found'}]) unless user_id.present?
        array_of_hashes = []
        list.each do |loc|
          loc_hash = {}
          if loc[:date].present? && loc[:time].present?
            loc_hash[:captured_at] = Time.zone.strptime("#{loc[:date]} #{loc[:time]}", "%Y-%m-%d %H:%M")
          end
          next if loc[:latitude].blank? || loc[:longitude].blank?

          loc_hash[:user_id] = user_id
          loc_hash[:latitude] = loc[:latitude]
          loc_hash[:longitude] = loc[:longitude]
          loc_hash[:accuracy] = loc[:accuracy]
          array_of_hashes << loc_hash
        end
        if Location.insert_all(array_of_hashes)
          return json_response({ message: 'Locations created successfully' })
        end
        json_error_response([{code: :create_failure, message: 'Unable to create locations'}])
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
        params.permit(:latitude, :longitude, :date, :time, :accuracy)
      end

      def update_params
        params.permit(:latitude, :longitude, :date, :time, :accuracy)
      end

      def bulk_create_params
        params.require(:list)
        params.permit(list: [:date, :time, :latitude, :longitude, :accuracy])
      end
    end
  end
end