Rails.application.routes.draw do
  get 'game', to: 'wordgames#game'

  get 'score', to: 'wordgames#score'

  get 'startover', to: 'wordgames#startover'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
