class AddProcessedToMatch < ActiveRecord::Migration[4.2]
  def change
    add_column :matches, :processed, :string
  end
end
