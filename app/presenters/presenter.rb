class Presenter < SimpleDelegator
  attr_reader :object

  def initialize(object)
    @object = object
    super
  end
end
