class ProductsController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :set_product, only: %i[show update destroy]
  rescue_from User::InvalidToken, with: :not_authorized


    def index
    if params[:store_id].present?
      @products = Product.not_deleted.where(store_id: params[:store_id]).includes(:image_attachment).all
    else
      @products = Product.all
    end
    respond_to do |format|
      format.html 
      format.json { render json: @products.map { |product| product.as_json(methods: :image_url) } }
    end
  end

  def products_store
    @store = Store.find(params[:store_id])
    @products = @store.products.includes(image_attachment: :blob)
    render json: @products.map { |product| product.as_json(methods: :image_url) }
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
      format.json { render json: @products.map { |product| product.as_json(methods: :image_url) } }
    end
  end

  def show
    render json: @product.as_json(methods: :image_url), status: :ok
  end

  def create
    @product = Product.new(product_params)
    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product.as_json(methods: :image_url), status: :created }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      if params[:product][:image].present?
        @product.image.attach(params[:product][:image])
      end
      render json: @product.as_json(methods: :image_url), status: :ok
    else
      render json: @product.errors, status: :unprocessable_entity
    end
  end
  
  def destroy
    @product = Product.find(params[:id])
    if @product.soft_delete
      render json: { message: "Produto excluído com sucesso." }, status: :ok
    else
      render json: { error: "Falha ao excluir produto." }, status: :unprocessable_entity
    end
  end


 private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:title, :price, :store_id, :image)
  end
end
