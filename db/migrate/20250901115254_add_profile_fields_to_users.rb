class AddProfileFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :favorite_foods, :text
    add_column :users, :disliked_foods, :text
    add_column :users, :profile_public, :boolean, default: true, null: false
  end
end
