class OauthBindingRequest < ActiveRecord::Base
  unloadable

  belongs_to :user
end