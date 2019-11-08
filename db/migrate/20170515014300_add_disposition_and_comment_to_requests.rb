class AddDispositionAndCommentToRequests < ActiveRecord::Migration[4.2]
  def change
    change_table :requests do |t|
      t.references :disposition, index: true, foreign_key: true
      t.string :comment
    end
  end
end
