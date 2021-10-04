class SecondFactor < ApplicationRecord
  OTP_ISSUER = 'keygen.example'

  belongs_to :user

  before_create :generate_otp_secret

  validates :user,
    presence: true

  scope :enabled,
    -> { where(enabled: true) }

  def provisioning_uri
    return nil if
      enabled?

    totp = ROTP::TOTP.new(otp_secret, issuer: OTP_ISSUER)

    totp.provisioning_uri(user.email)
  end

  def verify_with_otp(otp)
    totp = ROTP::TOTP.new(otp_secret, issuer: OTP_ISSUER)
    ts = totp.verify(otp.to_s, after: otp_verified_at.to_i)

    update(otp_verified_at: Time.at(ts)) if
      ts.present?

    ts
  end

  private

  def generate_otp_secret
    self.otp_secret = ROTP::Base32.random
  end
end
