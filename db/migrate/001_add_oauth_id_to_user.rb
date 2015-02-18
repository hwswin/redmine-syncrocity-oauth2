class AddOauthIdToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.integer :oauth_id
    end
  end

end
