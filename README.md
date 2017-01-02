# Product API
Simple APIs for product listing.


# Features

- Create/Read/Update/Delete product
- Upload image
- Use Soft deleted for default
- Integrate with Cloudinary for image hosting

# Installation

- Clone the project
- Config `.env` file (based on `.env.sample`)
- `bundle install`
- `rake db:migrate`
- `rails s`

# Example usage

- CRUD product

  + Get all products
  
    `curl -XGET localhost:3000/products`
    
  + Get info of a product
  
    `curl -XGET localhost:3000/products/1`
    
  + Create new product(without image)
  
    `curl -XPOST localhost:3000/products -d 'product[name]=NewBag&product[description]=nicebag&product[price]=100'`
    
  + Update product
  
    `curl -XPUT localhost:3000/products -d 'product[name]=NewBag&product[description]=nicebag&product[price]=100'`
    
  + Delete product
  
    `curl -XDELETE localhost:3000/products/1`

- Upload iamge

  `curl -XPOST localhost:3000/images -F image="@/Users/kevintran/Desktop/wip.png"`

  ```
    { "id":2,"url":"http://res.cloudinary.com/image-host1231443/image/upload/v1483341329/ucawtqkxob2xsq2kasod.png",
    "created_at":"2017-01-02T07:15:30.166Z","updated_at":"2017-01-02T07:15:30.166Z"}
  ```

- Create product with image

  `curl -XPOST localhost:3000/products \
  -d 'product[name]=NewBag&product[description]=nicebag&product[price]=100&product[product_images_attributes][][image_id]=2`

  ```
    {
      "id":11,"price":100.0,"name":"NewBag","description":"nicebag",
      "created_at":"2017-01-02T07:33:38.782Z","updated_at":"2017-01-02T07:33:38.782Z","deleted_at":null
    }
  ```

===

This project is powerd by `Rails 4.2.5.1` and `rails-api` gem.

