class Uploader
  # Public: Returned class for the upload process
  #   status       - A symbol status, can be :success or :failure
  #   error        - String error message
  #   image        - Image entity
  #   raw_response - Hash response of upload process
  #
  # Examples
  #
  #   resp = Uploader::Response.new(status: :success, image: image, raw_response: raw_response)
  #
  #   # Check the upload process status
  #   resp.success? # => true/fase
  #   # Get image url
  #   resp.image_url # => "https://abc.def/img1.png
  class Response
    def initialize(options = {})
      @status       = options[:status]
      @error        = options[:error]
      @image        = options[:image]
      @raw_response = options[:raw_response]
    end

    def image_url
      image ? image.url : nil
    end

    alias_method :url, :image_url

    def success?
      @status == :success
    end

    attr_reader :status, :error, :image, :raw_response
  end

  # Constructor of Uploader
  #
  # image_host - the upload host (default: Cloudinary::Uploader)
  # image_entity_klass - the image entity is created or built after the
  #   upload process finishes (default: Image)
  #
  # Examples
  #
  #   # Default usage
  #   uploader = Uploader.new
  #   uploader.upload("./image.png")
  #
  #   # Advanced usage
  #
  #   class CustomImageHost
  #     def upload(image, options = {}
  #       # your code to upload an image to host
  #       # return a hash of data, it is the info of the uploaded image.
  #       # at least, it includes 'url' key
  #       { url: 'https://uphost.com/img1.png' }
  #     end
  #   end
  #
  #   class ImageRepository
  #     def self.persist(response)
  #       # your code to persist the image from response
  #     end
  #
  #     def self.build(response
  #       # your code to build a new image from response
  #     end
  #   end
  #
  #   uploader = Uploader.new(
  #     image_host: CustomImageHost.new,
  #     image_entity_klass: ImageRepository
  #   )
  #
  #   uploader.upload("./image.png")
  def initialize(options = {})
    @image_host         = options[:image_host] || Cloudinary::Uploader
    @image_entity_klass = options[:image_entity_klass] || Image
  end

  # Public: This method will send image to image host
  #   and store image to the persistent datastore
  #
  # image - The Image file, can be a file, a string represent the path,
  #   or an url
  # persist_after_upload - The bool flag to indicate if user wants
  #   to store the image to persistent datastore
  # options - The hash options will be passed to image_host#upload method
  #
  # Examples
  #
  #   uploader = Uploader.new
  #
  #   # Basic usages
  #   uploader.upload("pic1.png")
  #
  #   # Just upload image, and don't store image to data store
  #   uploader.upload("pic1.png", false)
  #
  #   # We can pass arguments to options hash
  #   # If you are using Cloudinary service, checkout this link for all options
  #   # Please check http://cloudinary.com/documentation/rails_integration#configuration
  #
  #   args = {
  #     public_id: "123",
  #     crop: :limit, width: 500, height: 300,
  #     tags: ['special']
  #   }
  #
  #   uploader.upload("pic1.png", true, args)
  #
  # Return an Uploader::Response object
  def upload(image, persist_after_upload = true, options = {})
    upload_handler(
      image: image,
      persist_after_upload: persist_after_upload,
      success: success_callback,
      failure: failure_callback
    )
  end

  private

  # Internal: The success callback, it is called after upload process
  # finishes successfully.
  #
  # raw_response - The upload Response object
  # image_entity - The image object (refer Image model)
  #
  # Return a lambda function
  def success_callback
    lambda do |raw_response, image_entity|
      Response.new(
        status: :success,
        image: image_entity,
        raw_response: raw_response
      )
    end
  end

  # Internal: The failure callback, it is called when upload process
  # got errors
  #
  # error - The Error is raised during upload process
  #
  # Return a lambda function
  def failure_callback
    lambda do |error|
      error_handler(error)
      Response.new(
        status: :failure,
        error: error.message
      )
    end
  end

  # Internal: Handle the upload process, it does
  #   Upload image to @image_host
  #   If the process is success, run the success_callback
  #   If the process is fail, run the failure_callback
  #
  # image - The upload image
  # options - The upload options, check Uploader#upload method for more information
  # success_callback - The lambda callback that is called after upload successfully
  # failure_callback - The lambda callback that is called after upload unsuccessfully
  # persist_after_upload - The boolean flag determines to store uploaded image to persistent
  #   storage.
  #
  # Examples
  #
  #   success_callback = lambda -> { |resp, image_entity| puts image_entity.inspect }
  #   failure_callback = lambda -> { |err_msg| puts err_msg }
  #   persist_after_upload = false
  #   image = "./img1.png"
  #
  #   upload_handler(
  #     image: image,
  #     persist_after_upload: persist_after_upload,
  #     success: success_callback,
  #     failure: failure_callback
  #   )
  #
  # Return the output of success | failure callback
  def upload_handler(params = {})
    image                = params[:image]
    options              = params[:options] || {}
    success_proc         = params[:success]
    failure_proc         = params[:failure]
    persist_after_upload = params[:persist_after_upload]

    begin
      raw_response = image_host_upload(image, options)
      success_proc.call(
        raw_response,
        build_or_persist(raw_response, persist_after_upload)
      )
    rescue SocketError => e
      failure_proc.call(e)
    end
  end

  # Internal: Upload and wrap the response from image_host
  def image_host_upload(image, options)
    OpenStruct.new(@image_host.upload(image, options))
  end

  # Internal: Build or Persist image from raw response
  #
  #   raw_response - the response from image host when the upload process is sucessful
  #   persist_after_upload - the Boolean flag to persist image or just build an image object
  #
  # Examples
  #
  #  # This is a raw_response Object from Cloudinary
  #
  #  raw_response = OpenStruct.new(
  #    "public_id"=>"bp23d8dr6bj9bc8ixvdo",
  #   "version"=>1483208908,
  #   "signature"=>"c60fa99734b5aac8ed17c0fed54ddb4c82ac5bbe",
  #   "width"=>286, "height"=>253, "format"=>"png", "resource_type"=>"image",
  #   "created_at"=>"2016-12-31T18:28:28Z",
  #   "tags"=>[], "bytes"=>12157, "type"=>"upload",
  #   "etag"=>"5d72a4ef966f78964feafb59f7589958",
  #   "url"=>"http://cloudinary.com/image-host/image.png",
  #   "secure_url"=>"https://res.cloudinary.com/image-host1231443/image/upload/v1483208908/bp23d8dr6bj9bc8ixvdo.png",
  #   "original_filename"=>"wip"
  #  )
  #
  #  build_or_persist(raw_response, true) => #<Image id: 1, url: "http://res.cloudinary.com/image-host1231443/image/...">
  #
  # Returns an Image object
  def build_or_persist(raw_response, persist_after_upload)
    if persist_after_upload
      @image_entity_klass.persist(raw_response)
    else
      @image_entity_klass.build(raw_response)
    end
  end

  # Internal: Handle Error
  def error_handler(e)
    # TODO: report error
  end
end

