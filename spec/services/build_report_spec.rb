# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildReport do
  context 'building queries' do
    it 'can query for no additional fields' do
      fields = []
      start_date = nil
      end_date = nil
      preset_date_range = nil
      activity = 'FilledRequest'
      request_status = nil
      item_status = nil

      builder = BuildReport.new(fields, start_date, end_date, preset_date_range, activity, request_status, item_status)
      sql = builder.to_sql

      expected_sql = "SELECT DISTINCT Date_trunc('minute', a.created_at) AS \"activity\" FROM activity_logs a WHERE (a.action = 'FilledRequest') ORDER BY Date_trunc('minute', a.created_at)"

      expect(sql).to eql(expected_sql)
    end
  end
end
