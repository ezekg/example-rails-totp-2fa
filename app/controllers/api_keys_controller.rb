class ApiKeysController < ApplicationController
  prepend_before_action :authenticate_with_api_key!, only: %i[index destroy]

  def index
    render json: ApiKeyResource.new(current_bearer.api_keys)
  end

  def create
    authenticate_with_http_basic do |email, password|
      user = User.find_by(email: email)

      # Request or verify user's second factor if enabled.
      if user&.second_factor_enabled?
        otp = params[:otp]
        raise UnauthorizedRequestError, message: 'second factor is required', code: 'OTP_REQUIRED' unless
          otp.present?

        raise UnauthorizedRequestError, message: 'second factor is invalid', code: 'OTP_INVALID' unless
          user.authenticate_with_second_factor(otp: otp)
      end

      if user&.authenticate(password)
        api_key = user.api_keys.create!(token: SecureRandom.hex)

        render json: ApiKeyResource.new(api_key), status: :created and return
      end
    end

    render status: :unauthorized
  end

  def destroy
    api_key = current_bearer.api_keys.find(params[:id])

    api_key.destroy
  end
end
