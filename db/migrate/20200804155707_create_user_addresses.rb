class CreateUserAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :user_addresses do |t|
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :nickname, default: "Home"
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
