module Api
  module V1
    class RepairsController < BaseController
      before_action :authenticate

      def index
        repairs = Repair.newest_first.includes(*PRELOADS)
        repairs = repairs.where(status: state_filter) if params.key?(:state)
        render json: repairs.map { |repair| repair_document(repair) }
      end

      def show
        render json: repair_document(Repair.includes(*PRELOADS).find(params[:id]))
      end

      private

      PRELOADS = [:bike, :customer, { repair_line_items: :service_type }].freeze

      def state_filter
        state = params[:state]
        return state if state.is_a?(String) && Repair.statuses.key?(state)

        raise ActionController::BadRequest, "state must be one of: #{Repair.statuses.keys.join(", ")}"
      end

      # The total is added up from the loaded lines: Repair#total would run a
      # query for every repair.
      def repair_document(repair)
        lines = repair.repair_line_items.sort_by(&:id)
        {
          id: repair.id,
          state: repair.status,
          received_on: repair.dropped_off_at.to_date.iso8601,
          promised_on: repair.promised_on.iso8601,
          handed_back_on: repair.picked_up_at&.to_date&.iso8601,
          bike: {
            make: repair.bike.make,
            model: repair.bike.model,
            serial_number: repair.bike.serial_number
          },
          customer: { name: repair.customer.name },
          lines: lines.map { |line| { service: line.service_type.name, price_charged: money(line.price_charged) } },
          total: money(lines.sum(&:price_charged)),
          overdue: repair.overdue?,
          customer_answer: customer_answer(repair)
        }
      end

      # The lifecycle gives the customer a quote to answer. Once the bike is
      # picked up the status no longer says what the answer was.
      def customer_answer(repair)
        case repair.status
        when "awaiting_approval" then "awaiting_approval"
        when "in_progress", "ready" then "approved"
        when "declined" then "declined"
        end
      end
    end
  end
end
