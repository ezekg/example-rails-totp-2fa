class SecondFactorsController < ApplicationController
  prepend_before_action :authenticate_with_api_key!

  def index
    render json: SecondFactorResource.new(current_bearer.second_factors)
  end

  def show
    second_factor = current_bearer.second_factors.find(params[:id])

    render json: SecondFactorResource.new(second_factor)
  end

  def create
    second_factor = current_bearer.second_factors.new

    # Verify second factor if enabled, otherwise verify password.
    if current_bearer.second_factor_enabled?
      raise UnauthorizedRequestError, message: 'second factor must be valid', code: 'OTP_INVALID' unless
        current_bearer.authenticate_with_second_factor(otp: params[:otp])
    else
      raise UnauthorizedRequestError, message: 'password must be valid', code: 'PWD_INVALID' unless
        current_bearer.authenticate(params[:password])
    end

    second_factor.save!

    render json: SecondFactorResource.new(second_factor), status: :created
  end

  def update
    second_factor = current_bearer.second_factors.find(params[:id])

    # Verify this particular second factor (which may not be enabled yet).
    raise UnauthorizedRequestError, message: 'second factor must be valid', code: 'OTP_INVALID' unless
      second_factor.verify_with_otp(params[:otp])

    second_factor.update!(enabled: params[:enabled])

    render json: SecondFactorResource.new(second_factor)
  end

  def destroy
    second_factor = current_bearer.second_factors.find(params[:id])

    # Verify user's second factor if currently enabled.
    if current_user.second_factor_enabled?
      raise UnauthorizedRequestError, message: 'second factor must be valid', code: 'OTP_INVALID' unless
        current_bearer.authenticate_with_second_factor(otp: params[:otp])
    end

    second_factor.destroy
  end
end
