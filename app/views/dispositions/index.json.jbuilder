json.array!(@dispositions) do |disposition|
  json.extract! disposition, :id, :code, :description, :active
  json.url disposition_url(disposition, format: :json)
end
