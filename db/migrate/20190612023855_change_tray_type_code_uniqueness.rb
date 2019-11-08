class ChangeTrayTypeCodeUniqueness < ActiveRecord::Migration[4.2]
  def change
    reversible do |direction|
      direction.down do
        add_index "tray_types", ["code", "active"]

        add_index :tray_types, :code, unique: true
      end

      direction.up do
        remove_index :tray_types, :code

        add_index "tray_types", ["code", "active"], unique: true, where: "(active = true)"
      end
    end
  end
end
