Redmine::Plugin.register :redmine_oauth_client do
  name 'Redmine Oauth Client plugin'
  author 'Redmine CRM'
  description 'This is a plugin for setting up OAuth authentication in Redmine via Syncrocity'
  version '1.0.0'
  url 'http://redminecrm.com'
  author_url 'mailto:support@redminecrm.com'

  settings :default => {
    :notify_admin_on_new_users => true,
    :always_redirect_to_oauth => false
  }, :partial => 'settings/oauth'
end

require 'redmine_oauth_client'