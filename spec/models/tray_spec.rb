require 'rails_helper'

RSpec.describe Tray, type: :model do
  it { should_not validate_presence_of :shelf }
end
