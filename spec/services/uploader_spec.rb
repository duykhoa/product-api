require 'rails_helper'

class Uploader
  def initialize(options = {})
    @image_host = options[:image_host]
  end

  def upload(image, options = nil)
    @image_host.upload(image, options)
  end
end

class ImageHost
  attr_reader :uploaded_image

  def upload(image, option)
    @uploaded_image = image
  end
end

describe Uploader do
  let(:image_host) { ImageHost.new }
  let(:uploader) { Uploader.new(image_host: image_host) }

  describe "#upload" do
    let(:image_path) { './image.jpg' }

    it "accept an image" do
      uploader.upload(image_path)
    end

    it "accept a options" do
      options = {
        crop: :limit,
        width: 200, height: 200
      }

      uploader.upload(image_path, options)
    end

    it "call upload method from image_host object" do
      uploader.upload(image_path)
      expect(image_host.uploaded_image).to eq image_path
    end
  end
end
