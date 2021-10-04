class ApiKeyResource
  include Alba::Resource

  attributes :id, :created_at, :updated_at

  # Only display the token virtual attribute for newly saved tokens. Since
  # we're hashing the token before storing in the database, we aren't able
  # to read it after initial token creation.
  attributes :token,
    if: proc { |api_key| api_key.previously_new_record? }
end
