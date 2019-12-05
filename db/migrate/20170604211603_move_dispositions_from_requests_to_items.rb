class MoveDispositionsFromRequestsToItems < ActiveRecord::Migration[4.2]
  def change
    add_reference :items, :disposition, index: true, foreign_key: true
    remove_reference :requests, :disposition, index: true, foreign_key: true
  end
end
