require 'rails_helper'

RSpec.describe ProductsController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Product. As you add validations to Product, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    {
      name: 'product name',
      description: 'product description',
      price: 12.99
    }
  }

  let(:invalid_attributes) {
    {
      category: 'test'
    }
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ProductsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all products as @products" do
      product = Product.create! valid_attributes
      get :index, params: {}
      expect(assigns(:products)).to eq([product])
    end
  end

  describe "GET #show" do
    it "assigns the requested product as @product" do
      product = Product.create! valid_attributes
      get :show, id: product.to_param, session: valid_session
      expect(assigns(:product)).to eq(product)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Product" do
        expect {
          post :create, product: valid_attributes, session: valid_session
        }.to change(Product, :count).by(1)
      end

      it "assigns a newly created product as @product" do
        post :create, product: valid_attributes, session: valid_session
        expect(assigns(:product)).to be_a(Product)
        expect(assigns(:product)).to be_persisted
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved product as @product" do
        post :create, product: invalid_attributes, session: valid_session
        expect(assigns(:product)).to be_a(Product)
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        {
          name: 'new product name',
          description: 'new description'
        }
      }

      it "updates the requested product" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: new_attributes, session: valid_session
        product.reload
      end

      it "assigns the requested product as @product" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: valid_attributes, session: valid_session
        expect(assigns(:product)).to eq(product)
      end
    end

    context "with invalid params" do
      it "assigns the product as @product" do
        product = Product.create! valid_attributes
        put :update, id: product.to_param, product: invalid_attributes, session: valid_session
        expect(assigns(:product)).to eq(product)
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested product" do
      product = Product.create! valid_attributes
      expect {
        delete :destroy, id: product.to_param, session: valid_session
      }.to change(Product, :count).by(-1)
    end

  end
end
