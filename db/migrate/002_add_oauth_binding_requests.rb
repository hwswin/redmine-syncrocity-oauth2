class AddOauthBindingRequests < ActiveRecord::Migration
  def self.up
    create_table :oauth_binding_requests do |t|
      t.integer :oauth_id
      t.references :user, :null => false
      t.string :token
    end
  end

  def self.down
    drop_table :oauth_binding_requests
  end
end
