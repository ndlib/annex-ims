class AddUniquenessKeyToDispositions < ActiveRecord::Migration
  def change
    add_index :dispositions, :code, unique: true	  
  end
end
