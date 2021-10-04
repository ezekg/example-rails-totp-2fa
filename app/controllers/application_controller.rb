class ApplicationController < ActionController::API
  include ApiKeyAuthenticatable

  class UnauthorizedRequestError < StandardError
    attr_reader :code

    def initialize(message:, code: nil)
      @code = code

      super(message)
    end
  end

  rescue_from ActiveRecord::RecordInvalid, with: -> { render status: :unprocessable_entity }
  rescue_from ActiveRecord::RecordNotUnique, with: -> { render status: :conflict }
  rescue_from ActiveRecord::RecordNotFound, with: -> { render status: :not_found }

  rescue_from UnauthorizedRequestError do |e|
    error = { message: e.message, code: e.code }

    render json: { error: error }, status: :unauthorized
  end
end
