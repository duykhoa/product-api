require 'rails_helper'

class Uploader
  def initialize(options = {})
    @image_host = options[:image_host]
  end

  def upload(image, options = nil)
    with_error_handler do
      @image_host.upload(image, options)
    end
  end

  def with_error_handler(&block)
    begin
      block.call
    rescue SocketError => e
      error_handler(e)
    end
  end

  def error_handler(e)
    # TODO: report error
    nil
  end
end

class ImageHost
  attr_reader :uploaded_image

  def upload(image, option)
    @uploaded_image = image
  end
end

class WithErrorImageHost
  def upload(image, option)
    raise SocketError, "Failed to open TCP connection"
  end
end

class RealRepsonseImageHost
  attr_reader :uploaded_image

  def upload(image, option)
    {
      "public_id"=>"bp23d8dr6bj9bc8ixvdo",
     "version"=>1483208908,
     "signature"=>"c60fa99734b5aac8ed17c0fed54ddb4c82ac5bbe",
     "width"=>286, "height"=>253, "format"=>"png", "resource_type"=>"image",
     "created_at"=>"2016-12-31T18:28:28Z",
     "tags"=>[], "bytes"=>12157, "type"=>"upload",
     "etag"=>"5d72a4ef966f78964feafb59f7589958",
     "url"=>"http://res.cloudinary.com/image-host1231443/image/upload/v1483208908/bp23d8dr6bj9bc8ixvdo.png",
     "secure_url"=>"https://res.cloudinary.com/image-host1231443/image/upload/v1483208908/bp23d8dr6bj9bc8ixvdo.png",
     "original_filename"=>"wip"
    }
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

    it "can handle error" do
      uploader = Uploader.new(image_host: WithErrorImageHost.new)
      expect { uploader.upload(image_path) }.not_to raise_error
    end
  end
end
