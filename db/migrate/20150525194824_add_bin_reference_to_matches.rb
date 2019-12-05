class AddBinReferenceToMatches < ActiveRecord::Migration[4.2]
  class Match < ApplicationRecord
    belongs_to :item, class_name: 'AddBinReferenceToMatches::Item'
    belongs_to :bin, class_name: 'AddBinReferenceToMatches::Bin'
  end

  class Item < ApplicationRecord
    belongs_to :bin, class_name: 'AddBinReferenceToMatches::Bin'
    has_many :matches, -> { order('updated_at desc') }, class_name: 'AddBinReferenceToMatches::Match'
  end

  class Bin < ApplicationRecord
    has_many :items, class_name: 'AddBinReferenceToMatches::Item'
    has_many :matches, class_name: 'AddBinReferenceToMatches::Match'
  end

  def up
    change_table :matches do |t|
      t.timestamps
    end

    add_reference :matches, :bin, index: true
    add_foreign_key :matches, :bins

    Match.reset_column_information
    Bin.all.each do |bin|
      bin.items.each do |item|
        match = item.matches.first
        if !match.blank?
          bin.matches << match
        else
          item.bin = nil
          item.save!
        end
      end

      bin.save!
    end
  end

  def down
    remove_foreign_key :matches, :bins
    remove_reference :matches, :bin

    remove_column :matches, :created_at
    remove_column :matches, :updated_at
  end
end
