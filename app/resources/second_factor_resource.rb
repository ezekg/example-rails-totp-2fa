class SecondFactorResource
  include Alba::Resource

  attributes :id, :enabled, :created_at, :updated_at

  # Only display the OTP secret attribute when second factor has
  # not been enabled yet (so we don't leak after enabling).
  attributes :otp_secret, :provisioning_uri,
    if: proc { |second_factor| !second_factor.enabled? }
end
