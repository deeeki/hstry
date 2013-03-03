class CreateHistories < ActiveRecord::Migration
  def change
    create_table :histories do |t|
      t.references :user, index: true
      t.string :uid
      t.string :provider
      t.string :resource
      t.text :text
      t.string :image
      t.string :url
      t.datetime :published_at
      t.text :location
      t.text :data

      t.timestamps
    end
    add_index :histories, :published_at
  end
end
