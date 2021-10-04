Rails.application.routes.draw do
  resources :api_keys, path: 'api-keys', only: %i[index create destroy]
  resources :second_factors, path: 'second-factors'
end
