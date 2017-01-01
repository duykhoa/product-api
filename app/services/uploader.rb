class Uploader
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

  def initialize(options = {})
    @image_host         = options[:image_host] || Cloudinary::Uploader
    @image_entity_klass = options[:image_entity_klass] || Image
  end

  def upload(image, persist_after_upload = true, options = {})
    upload_handler(
      image: image,
      persist_after_upload: persist_after_upload,
      success: success_callback,
      failure: failure_callback
    )
  end

  def success_callback
    lambda do |raw_response, image_entity|
      Response.new(
        status: :success,
        image: image_entity,
        raw_response: raw_response
      )
    end
  end

  def failure_callback
    lambda do |error|
      error_handler(error)
      Response.new(
        status: :failure,
        error: error.message
      )
    end
  end

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

  def image_host_upload(image, options)
    raw_response = @image_host.upload(image, options)
    OpenStruct.new(raw_response)
  end

  def build_or_persist(raw_response, persist_after_upload)
    if persist_after_upload
      @image_entity_klass.persist(raw_response)
    else
      @image_entity_klass.build(raw_response)
    end
  end

  def error_handler(e)
    # TODO: report error
  end
end

