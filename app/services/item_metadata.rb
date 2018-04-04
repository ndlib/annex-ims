module ItemMetadata
  def map_item_attributes(data)
    {
      barcode: data[:barcode],
      title: data[:title],
      author: data[:author],
      chron: data[:description],
      bib_number: data[:bib_id],
      isbn_issn: data[:isbn_issn],
      conditions: data[:condition],
      call_number: data[:call_number],
    }
  end

  # If there is any error in the response status, or with the data in the response,
  # get_error will return a json { type:, status:, issue:, enqueue: }
  # otherwise if there are no errors in the response, will return nil
  def get_error(response)
    if response.success?
      get_data_error(response)
    elsif response.not_found?
      { type: :not_found, status: :not_found, issue_type: "not_found" }
    elsif response.unauthorized?
      { type: :unauthorized, status: :error, enqueue: true }
    elsif response.timeout?
      { type: :timeout, status: :error, enqueue: true }
    else
      { type: :unknown, status: :error, enqueue: true }
    end
  end

  # Check to see if there is any error in the data received from from the api
  # If there is an error, get_data_error will return a json { type:, status:, issue:, enqueue: }
  # otherwise if there are no errors with the data, will return nil
  def get_data_error(response)
    if !(response.body.has_key?(:sublibrary)) || response.body[:sublibrary] != "ANNEX"
      { type: :not_for_annex, status: :not_for_annex, issue_type: "not_for_annex" }
    end
  end

  def user
    @user ||= User.where(id: user_id).take
  end

  def metadata_status_attributes(status)
    {
      metadata_status: status,
      metadata_updated_at: Time.now,
    }
  end

end
