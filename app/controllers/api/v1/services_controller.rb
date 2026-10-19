module Api
  module V1
    class ServicesController < BaseController
      before_action :authenticate, only: :create

      wrap_parameters :service, include: [:name, :price], format: :json

      def index
        render json: services_with_repairs_count.map { |service| service_document(service, service.repairs_count) }
      end

      def show
        service = services_with_repairs_count.find(params[:id])
        render json: service_document(service, service.repairs_count)
      end

      def create
        service = ServiceType.new(service_params)
        if service.save
          render json: service_document(service, 0), status: :created, location: api_v1_service_url(service)
        else
          render_errors(service.errors.full_messages, status: :unprocessable_entity)
        end
      end

      private

      # repairs_count is distinct repairs: a repair can charge a service twice.
      def services_with_repairs_count
        ServiceType.by_name
          .left_joins(:repair_line_items)
          .group(:id)
          .select("service_types.*", "COUNT(DISTINCT repair_line_items.repair_id) AS repairs_count")
      end

      def service_document(service, repairs_count)
        {
          id: service.id,
          name: service.name,
          price: money(service.current_price),
          repairs_count: repairs_count
        }
      end

      def service_params
        permitted = params.expect(service: [:name, :price])
        raise ActionController::ParameterMissing, :service if permitted.empty?

        { name: permitted[:name], current_price: permitted[:price] }
      end
    end
  end
end
