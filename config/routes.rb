Rails.application.routes.draw do
  resources :loans, defaults: {format: :json} do
    post :create_payment, on: :collection
  end

  resources :payments, defaults: {format: :json}

end
