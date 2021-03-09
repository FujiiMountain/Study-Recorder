class AddChangeEmailColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :change_digest, :string
    add_column :users, :change_sent_at, :datetime
  end
end
