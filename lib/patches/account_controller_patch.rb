module RedmineOauthClient
  module Patches
    module AccountControllerPatch
      def self.included(base)
        base.send(:include, InstanceMethods)

        base.class_eval do
          before_filter :redirect_to_oauth, :only => :login
        end
      end

      module InstanceMethods
        def redirect_to_oauth
          redirect_to oauth_login_path if Setting.plugin_redmine_oauth_client[:always_redirect_to_oauth]
        end

      end
    end
  end
end

unless AccountController.included_modules.include?(RedmineOauthClient::Patches::AccountControllerPatch)
  AccountController.send(:include, RedmineOauthClient::Patches::AccountControllerPatch)
end
