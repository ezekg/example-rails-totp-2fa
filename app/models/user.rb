class User < ApplicationRecord
  has_many :api_keys, as: :bearer

  # We're using a has-many here, but effectually it's a has-one since we have
  # a unique index on the user_id column. We can remove the unique index in
  # the future to support multiple second factors per-user.
  has_many :second_factors

  def second_factor_enabled?
    second_factors.enabled.any?
  end

  def authenticate_with_second_factor(otp:)
    return false unless
      second_factor_enabled?

    # We only allow a single 2FA key right now, but we may allow more later,
    # e.g. multiple 2FA keys, backup codes, or U2F.
    second_factor = second_factors.enabled.last

    second_factor.verify_with_otp(otp)
  end

  has_secure_password
end
