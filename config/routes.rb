Rails.application.routes.draw do
  root "main#index"
  post "create-site", to: "main#create_site"
  post "update-form", to: "main#update_form"
end
