class AddIssueTypeToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :issue_type, :string, null: false
    remove_column :issues, :message
  end
end
