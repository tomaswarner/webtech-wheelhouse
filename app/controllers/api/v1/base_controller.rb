module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActionController::ParameterMissing, with: :missing_parameters
      rescue_from ActiveRecord::RangeError, with: :number_out_of_range

      # The params wrapper and the request log read the parameters outside of
      # rescue_from, so a body that is not JSON, or a query string that can't
      # be read, is caught here, around the whole action.
      def process_action(*)
        super
      rescue ActionDispatch::Http::Parameters::ParseError
        render_errors("The request body is not valid JSON", status: :bad_request)
      rescue ActionController::BadRequest => error
        render_errors(error.message, status: :bad_request)
      end

      def route_not_found
        render_errors("There is no route for #{request.request_method} #{request.path}", status: :not_found)
      end

      private

      def authenticate
        authenticate_with_http_token do |token, _options|
          expected = Rails.application.credentials.api_token
          expected.present? && token_matches?(token, expected)
        end || render_unauthorized
      end

      # Digests have the same length whatever the token is, so the comparison
      # does not leak the length either.
      def token_matches?(given, expected)
        ActiveSupport::SecurityUtils.secure_compare(Digest::SHA256.hexdigest(given), Digest::SHA256.hexdigest(expected))
      end

      def render_unauthorized
        response.set_header("WWW-Authenticate", %(Bearer realm="Wheelhouse"))
        render_errors("A valid token is required in the Authorization header", status: :unauthorized)
      end

      def render_errors(messages, status:)
        render json: { errors: Array(messages) }, status: status
      end

      def record_not_found(error)
        render_errors("There is no #{error.model.to_s.underscore.humanize.downcase} with id #{error.id}", status: :not_found)
      end

      def missing_parameters(error)
        render_errors("The body has no #{error.param} attributes", status: :bad_request)
      end

      def number_out_of_range
        render_errors("A number in the request is out of range", status: :unprocessable_entity)
      end

      # Money travels as a string with two decimals: the column is a decimal,
      # and a JSON number would pass through a float.
      def money(amount)
        format("%.2f", amount)
      end
    end
  end
end
