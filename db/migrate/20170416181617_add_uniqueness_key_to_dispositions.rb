class AddUniquenessKeyToDispositions < ActiveRecord::Migration[4.2]
  def change
    add_index :dispositions, :code, unique: true	  
  end
end
