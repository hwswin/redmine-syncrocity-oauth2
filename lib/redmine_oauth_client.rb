Rails.configuration.to_prepare do
  require_dependency 'patches/account_controller_patch'
end