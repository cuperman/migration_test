MigrationTest::Application.routes.draw do
  resources :people

  root :to => 'people#index'

  get "/delayed_job" => DelayedJobWeb, :anchor => false
end
