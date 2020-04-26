# frozen_string_literal: true

class ActivityLog < ApplicationRecord
  belongs_to :user

  validates :action_timestamp, presence: true
  validates :action, presence: true
  validates :data, presence: true

  ACTIONS = %w[
    AcceptedItem
    ApiDeaccessionItem
    ApiGetItemMetadata
    ApiGetRequestList
    ApiRemoveRequest
    ApiScanItem
    ApiSendItem
    ApiStockItem
    AssociatedItemAndBin
    AssociatedItemAndTray
    AssociatedTrayAndShelf
    BatchedRequest
    CreatedIssue
    CreatedItem
    CreatedTransfer
    CreatedTrayIssue
    CreatedTray
    DeaccessionedItem
    DestroyedItem
    DestroyedTransfer
    DissociatedItemAndBin
    DissociatedItemAndTray
    DissociatedTrayAndShelf
    FilledRequest
    MatchedItem
    ReceivedRequest
    RemovedMatch
    RemovedRequest
    ResolvedIssue
    ResolvedTrayIssue
    ScannedItem
    SetItemDisposition
    ShelvedTray
    ShippedItem
    SkippedItem
    StockedItem
    UnshelvedTray
    UnstockedItem
    UpdatedBarcode
    UpdatedItemMetadata
  ].freeze
end
