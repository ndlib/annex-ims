require 'rails_helper'

RSpec.describe GetUserType do
  it "returns 'admin' for an user with admin type" do
    user = FactoryGirl.create(:user, id: 1, admin: true)
    expect(GetUserType.call(user)).to eq('admin')
    expect(GetUserType.call(user)).to_not eq('worker')
  end

  it "returns 'worker' for an user with worker type" do
    user = FactoryGirl.create(:user, id: 1, worker: true)
    expect(GetUserType.call(user)).to eq('worker')
    expect(GetUserType.call(user)).to_not eq('admin')
  end

  it "returns 'disabled' for an user without any type" do
    user = FactoryGirl.create(:user, id: 1)
    expect(GetUserType.call(user)).to eq('disabled')
    expect(GetUserType.call(user)).to_not eq('worker')
    expect(GetUserType.call(user)).to_not eq('admin')
  end

  it "returns 'disabled' for an user without admin and worker types" do
    user = FactoryGirl.create(:user, id: 1, admin: false, worker: false)
    expect(GetUserType.call(user)).to eq('disabled')
    expect(GetUserType.call(user)).to_not eq('worker')
    expect(GetUserType.call(user)).to_not eq('admin')
  end

  it "returns 'nil' for an user with both admin and worker types" do
    user = FactoryGirl.create(:user, id: 1, admin: true, worker: true)
    expect(GetUserType.call(user)).to eq(nil)
    expect(GetUserType.call(user)).to_not eq('admin')
    expect(GetUserType.call(user)).to_not eq('worker')
    expect(GetUserType.call(user)).to_not eq('disabled')
  end
end
