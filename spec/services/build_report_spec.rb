# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BuildReport do
  context 'building queries' do
    it 'can query for no additional fields' do
      fields = []
      start_date = nil
      end_date = nil
      activity = 'FilledRequest'
      status = nil

      builder = BuildReport.new(fields, start_date, end_date, activity, status)
      sql = builder.to_sql

      expected_sql = "SELECT a.created_at AS \"activity\" FROM activity_logs a WHERE (a.action = 'FilledRequest') ORDER BY a.created_at"

      expect(sql).to eql(expected_sql)
    end
  end
end
