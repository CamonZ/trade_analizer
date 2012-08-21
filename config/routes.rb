TradeAnalizer::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)



  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  match 'trading_days/:date' => 'trading_days#show', :as => :trading_day_date, :constraints => { :date => /\d{4}-\d{2}-\d{2}/ }
  match 'trading_days/:date/statistics' => 'trading_days#statistics', :as => :trading_day_statistics, :constraints => { :date => /\d{4}-\d{2}-\d{2}/ }
  match 'trading_days/:date/:symbol/statistics' => 'profit_and_loss_statistics#statistics', :as => :stock_profit_and_losses_by_date_statistics, :constraints => { :date => /\d{4}-\d{2}-\d{2}/, :symbol => /\w{1,4}/ }
  
  match '/dashboard/upload' => 'dashboard#upload', :as => :dashboard_upload, :method => :post
  match '/dashboard/statistics' => 'dashboard#statistics', :as => :dashboard_statistics
  match '/dashboard' => 'dashboard#index', :as => :dashboard_index
  
  
  resources :trading_days do
    member do
      get 'statistics'
    end
  end
  root :to => 'dashboard#index'
end
