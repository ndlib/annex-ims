class ChangeNameToCode < ActiveRecord::Migration[4.2]
  def change
    change_table :dispositions do |t|
      t.rename :name, :code
    end
  end
end
