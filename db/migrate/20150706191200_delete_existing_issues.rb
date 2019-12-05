class DeleteExistingIssues < ActiveRecord::Migration[4.2]
  class Issue < ApplicationRecord
  end

  def change
    Issue.destroy_all
  end
end
