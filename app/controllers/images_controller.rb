class ImagesController < ApplicationController
  def create
    uploader = Uploader.new
    upload_response = uploader.upload(image_file)

    if upload_response.success?
      if upload_response.image.persisted?
        render json: upload_response.image, status: :created
      else
        render json: upload_response.image, status: :unprocessable_entity
      end
    else
      render json: upload_response.error, status: :unprocessable_entity
    end
  end

  def image_file
    params.require(:image).tempfile
  end
end
