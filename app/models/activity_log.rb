# frozen_string_literal: true

class ActivityLog < ApplicationRecord
  belongs_to :user

  validates :action_timestamp, presence: true
  validates :action, presence: true
  validates :data, presence: true

  ACTION_TABLES = {
    'AcceptedItem' => ['items', 'requests'],
    'ApiDeaccessionItem' => ['items'],
    'ApiGetItemMetadata' => ['items'],
    'ApiGetRequestList' => [],
    'ApiRemoveRequest' => ['requests'],
    'ApiScanItem' => ['items'],
    'ApiSendItem' => ['items'],
    'ApiStockItem' => ['items'],
    'AssociatedItemAndBin' => ['bins', 'items'],
    'AssociatedItemAndTray' => ['items', 'trays'],
    'AssociatedTrayAndShelf' => ['shelves', 'trays'],
    'BatchedRequest' => ['requests'],
    'CreatedIssue' => ['issues', 'items'],
    'CreatedItem' => ['items'],
    'CreatedTransfer' => ['shelves', 'transfers'],
    'CreatedTrayIssue' => ['tray_issues', 'trays'],
    'CreatedTray' => ['trays'],
    'DeaccessionedItem' => ['dispositions', 'items'],
    'DestroyedItem' => ['items'],
    'DestroyedTransfer' => ['shelves', 'transfers'],
    'DissociatedItemAndBin' => ['bins', 'items'],
    'DissociatedItemAndTray' => ['items', 'trays'],
    'DissociatedTrayAndShelf' => ['shelves', 'trays'],
    'FilledRequest' => ['requests'],
    'MatchedItem' => ['items', 'requests'],
    'ReceivedRequest' => ['requests'],
    'RemovedMatch' => ['items', 'requests'],
    'RemovedRequest' => ['requests'],
    'ResolvedIssue' => ['items', 'issues'],
    'ResolvedTrayIssue' => ['tray_issues', 'trays'],
    'ScannedItem' => ['items', 'requests'],
    'SetItemDisposition' => ['dispositions', 'items'],
    'ShelvedTray' => ['shelves', 'trays'],
    'ShippedItem' => ['items', 'requests'],
    'SkippedItem' => ['items', 'requests'],
    'StockedItem' => ['items', 'trays'],
    'UnshelvedTray' => ['shelves', 'trays'],
    'UnstockedItem' => ['items', 'trays'],
    'UpdatedBarcode' => ['items'],
    'UpdatedItemMetadata' => ['items']
  }.freeze

  ACTIONS = ACTION_TABLES.keys.freeze
end
