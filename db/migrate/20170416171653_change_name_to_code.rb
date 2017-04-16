class ChangeNameToCode < ActiveRecord::Migration
  def change
    change_table :dispositions do |t|
      t.rename :name, :code
    end
  end
end
