class ProductsController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!


  before_action :set_product, only: %i[show update destroy]
  rescue_from User::InvalidToken, with: :not_authorized

  def index
    if params[:store_id].present?
      @products = Product.where(store_id: params[:store_id])
    else
      @products = Product.all
    end
    respond_to do |format|
      format.html # render padrão (index.html.erb)
      format.json { render json: @products }
    end
  end

  def products_store
    @store = Store.find(params[:store_id])
    @products = @store.products
    render json: @products
  end
  
  def listing
    if current_user.admin?
      @products = Product.includes(:store)
    elsif current_user.seller?
      @products = Product.where(store_id: current_user.store_ids).includes(:store)
    else
      respond_to do |format|
        format.html { redirect_to root_path, notice: "No permission for you!" }
        format.json { render json: { error: "No permission for you!" }, status: :forbidden }
      end
      return
    end
    respond_to do |format|
      format.html 
      format.json { render json: @products }
    end
  end

  def show
  
    render json: @product

  end

  def create
    @product = Product.new(product_params)
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @product.update(product_params)
      
      render json: @product, status: :ok
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @product.destroy
      respond_to do |format|
        format.html { redirect_to products_url, notice: 'Product was successfully destroyed from store.' }
        format.json { render json: { message: "Product destroyed from store!" }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to products_url, alert: 'Product could not be destroyed from store.' }
        format.json { render json: { error: "Failed to destroy product from store." }, status: :unprocessable_entity }
      end
    end
  end
  private

  def set_product
    # @product = Product.find(params[:id])
    @store = Store.find(params[:store_id])
    @product = @store.products.find(params[:product_id])
    # @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :price, :store_id)
  end
 
end
