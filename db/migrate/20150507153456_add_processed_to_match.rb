class AddProcessedToMatch < ActiveRecord::Migration
  def change
    add_column :matches, :processed, :string
  end
end
