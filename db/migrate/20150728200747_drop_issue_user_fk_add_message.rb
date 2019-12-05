class DropIssueUserFkAddMessage < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :issues, column: :user_id
    add_column :issues, :message, :string
    change_column_null :issues, :user_id, true
  end
end
