require "rails_helper"

RSpec.describe CompleteRequest do
  let(:user) { instance_double(User) }
  let(:request) { instance_double(Request, completed!: true, completed?: false) }

  it "changes the status of the request to completed" do
    expect(request).to receive(:completed!)
    allow(ActivityLogger).to receive(:fill_request)
    described_class.call(request: request, user: user)
  end

  it "logs an activity" do
    expect(ActivityLogger).to receive(:fill_request)
    described_class.call(request: request, user: user)
  end

  it "does not log an activity if the request was already completed" do
    allow(request).to receive(:completed?).and_return(true)
    expect(ActivityLogger).not_to receive(:fill_request)
    request.completed!
    described_class.call(request: request, user: user)
  end
end
