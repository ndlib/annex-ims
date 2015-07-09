class Simulator
  attr_reader :current_user

  def initialize(current_user: nil)
    @current_user = current_user || create_user
  end

  def create_tray
    Tray.new(AnnexFaker::Tray.attributes) do |tray|
      5.times do
        if tray.save
          break
        else
          tray.barcode = AnnexFaker::Tray.barcode
        end
        tray.validate!
      end
    end
  end

  def create_shelf
    Shelf.new(AnnexFaker::Shelf.attributes) do |shelf|
      5.times do
        if shelf.save
          break
        else
          shelf.barcode = AnnexFaker::Shelf.barcode
        end
        shelf.validate!
      end
    end
  end

  def create_item
    Item.new(AnnexFaker::Item.attributes) do |item|
      item.save!(validate: false)
    end
  end

  def create_and_log_item
    create_item.tap do |item|
      ActivityLogger.create_item(item: item, user: current_user)
    end
  end

  def create_request(**attributes)
    Request.new(AnnexFaker::Request.attributes(**attributes)) do |request|
      request.save!
    end
  end

  def create_user
    User.new(AnnexFaker::User.attributes) do |user|
      5.times do
        if user.save
          break
        else
          user.username = AnnexFaker::User.username
        end
      end
      user.validate!
    end
  end
end