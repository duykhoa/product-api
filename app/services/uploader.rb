class Uploader
  #TODO Implement their behavior
  class ImageObject < OpenStruct;end
  class NullImageObject < OpenStruct;end

  def initialize(options = {})
    @image_host = options[:image_host]
  end

  def upload(image, options = nil)
    to_object(with_error_handler { @image_host.upload(image, options) })
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

  def to_object(raw_data)
    if raw_data.is_a?(Hash)
      ImageObject.new(raw_data)
    else
      NullImageObject.new(raw_data)
    end
  end
end

