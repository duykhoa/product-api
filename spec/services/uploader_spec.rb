require 'rails_helper'

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
     "url"=>"http://cloudinary.com/image-host/image.png",
     "secure_url"=>"https://res.cloudinary.com/image-host1231443/image/upload/v1483208908/bp23d8dr6bj9bc8ixvdo.png",
     "original_filename"=>"wip"
    }
  end
end

describe Uploader do
  let(:image_host) { RealRepsonseImageHost.new }
  let(:uploader) { Uploader.new(image_host: image_host) }
  let(:uploaded_image_url) { "http://cloudinary.com/image-host/image.png" }

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

    it "can handle SocketError" do
      uploader = Uploader.new(image_host: WithErrorImageHost.new)
      expect { uploader.upload(image_path) }.not_to raise_error
    end

    context "response object" do
      it "returns an image object" do
        response = uploader.upload(image_path)
        expect(response.url).to eq uploaded_image_url
      end

      it "returns image_url when error" do
        uploader = Uploader.new(image_host: WithErrorImageHost.new)
        response = uploader.upload(image_path)
        expect(response.url).to be nil
      end

      it "return error msg" do
        uploader = Uploader.new(image_host: WithErrorImageHost.new)
        response = uploader.upload(image_path)
        expect(response.error).to eq "Failed to open TCP connection"
      end

      it "can persist data to db" do
        uploader = Uploader.new(image_host: RealRepsonseImageHost.new)

        expect{
          uploader.upload(image_path, true)
        }.to change(Image, :count).by(1)
      end

      it "can't persist when error" do
        uploader = Uploader.new(image_host: WithErrorImageHost.new)

        expect{
          uploader.upload(image_path, true)
        }.to change(Image, :count).by(0)
      end
    end
  end
end
