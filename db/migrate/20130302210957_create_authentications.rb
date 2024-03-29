class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.references :user, index: true
      t.string :provider
      t.string :uid
      t.string :name
      t.string :email
      t.string :image
      t.string :token
      t.string :secret

      t.timestamps
    end
  end
end
