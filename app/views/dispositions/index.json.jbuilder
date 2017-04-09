json.array!(@dispositions) do |disposition|
  json.extract! disposition, :id, :name, :description, :active
  json.url disposition_url(disposition, format: :json)
end
