class ApiKey < ApplicationRecord
  HMAC_SECRET_KEY = ENV.fetch('API_KEY_HMAC_SECRET_KEY')

  # Virtual attribute for raw token value, allowing us to respond with the
  # API key's non-hashed token value. but only for newly created tokens.
  attr_accessor :token

  belongs_to :bearer,
    polymorphic: true

  before_create :generate_token_hmac

  def self.authenticate_by_token!(token)
    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token

    find_by! token_digest: digest
  end

  def self.authenticate_by_token(token)
    authenticate_by_token! token
  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

  def generate_token_hmac
    raise ActiveRecord::RecordInvalid, 'token is required' unless token.present?

    digest = OpenSSL::HMAC.hexdigest 'SHA256', HMAC_SECRET_KEY, token

    self.token_digest = digest
  end
end
