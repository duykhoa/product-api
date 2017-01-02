class Image < ActiveRecord::Base
  # Public: create an image from upload image
  def self.persist(upload_image)
    create(url: upload_image.url)
  end

  # Public: build an image from upload image
  def self.build(upload_image)
    new(url: upload_image.url)
  end
end
