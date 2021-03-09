class AddUserIdToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :user_id, :integer
    add_foreign_key :tasks, :users
  end
end
