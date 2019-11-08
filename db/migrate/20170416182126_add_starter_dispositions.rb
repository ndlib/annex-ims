class AddStarterDispositions < ActiveRecord::Migration[4.2]
  def up
    Disposition.create(code: 'Campus-Return', description: 'Item transferred back to campus library')
    Disposition.create(code: 'WDR-Damaged', description: 'Item withdrawn due to damaged condition')
  end

  def down
    Disposition.find_by_code('Campus-Return').destroy
    Disposition.find_by_code('WDR-Damaged').destroy
  end
end
