class UserResource
  include Alba::Resource

  attributes :id, :email, :created_at, :updated_at
end
