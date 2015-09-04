class AddUsersLastActivity < ActiveRecord::Migration
  def change
    add_column :users, :last_activity_at, :datetime
  end
end
