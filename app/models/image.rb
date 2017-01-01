class Image < ActiveRecord::Base
  def self.persist(upload_image)
    create(url: upload_image.url)
  end

  def self.build(upload_image)
    new(url: upload_image.url)
  end
end
