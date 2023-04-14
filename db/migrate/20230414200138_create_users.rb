class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.datetime :postmark_error_at

      t.timestamps
    end
  end
end
