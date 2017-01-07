def create_product(name, description, price, image)
  Product.create(name: name, description: description, price: price, images: [image])
end

def upload_images(image_path)
  Uploader.new.upload(image_path)
end

def clear
  Product.delete_all
  Image.delete_all
end

def image_path
  File.join(Rails.root, "public/assets/images")
end

def seeding
  printf "Start seeding! It will take a bit of time\n"
  clear

  (1..5).each do |i|
    img = upload_images("#{image_path}/img#{i}.jpg").image
    create_product("Product Name #{i}", "Product Description #{i}", rand(100), img)
  end

  printf "Finish seeding!\n"
end

seeding
