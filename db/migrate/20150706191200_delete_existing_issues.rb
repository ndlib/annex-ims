class DeleteExistingIssues < ActiveRecord::Migration
  class Issue < ActiveRecord::Base
  end

  def change
    Issue.destroy_all
  end
end
