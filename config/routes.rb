# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/oauth/login' => 'oauth#login', as: :oauth_login
get '/oauth/callback' => 'oauth#callback', as: :oauth_callback
get '/oauth/bind/:id/:oauth_id' => 'oauth#request_oauth_binding_permission', as: :request_oauth_binding_permission
post '/oauth/submit/:id/:oauth_id' => 'oauth#submit_oauth_binding_permission', as: :submit_oauth_binding_permission
get '/oauth/confirm/:token' => 'oauth#confirm_binding', as: :confirm_oauth_binding
