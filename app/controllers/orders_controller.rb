class OrdersController < ApplicationController
  skip_forgery_protection
  before_action :authenticate!
  before_action :set_buyer, only: [:update]
  before_action :set_order, only: [:edit, :update, :show]

  def new
    @order = Order.new
    @order.order_items.build 
    @buyers = User.where(role: 'buyer') if current_user.admin? 
    @products = Product.all 
  end

  def edit
  end

  def show
  end
  
  def create
    @order = Order.new(order_params)
    @order.buyer = current_user if current_user&.role == 'buyer'

    if @order.save
      respond_to do |format|
        format.html { redirect_to @order, notice: 'Pedido criado com sucesso.' }
        format.json { render json: @order.as_json(include: { order_items: { include: :product } }), status: :created }
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: { errors: @order.errors }, status: :unprocessable_entity }
      end
    end
  end

  def index
    if current_user.role == 'buyer'
      @orders = Order.where(buyer_id: current_user.id)
    elsif current_user.role == 'admin'
      @orders = Order.all
    end

    respond_to do |format|
      format.html
      format.json { render json: @orders.as_json(include: { order_items: { include: :product } }) }
    end
  end

  def update
    if @order.update(order_params)
      redirect_to @order, notice: 'Pedido atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to orders_url, notice: 'Pedido excluído com sucesso.'
  end

  rescue_from User::InvalidToken, with: :not_authorized

  private

  def set_order
    @order = Order.find(params[:id])
  end

  def set_buyer
    @buyer = Buyer.find_by(id: order_params[:buyer_id])
  end

  def only_buyers!
    if current_user.nil? || current_user.role != 'buyer'
      respond_to do |format|
        format.html { redirect_to root_path, alert: 'Acesso negado: Apenas compradores podem acessar esta página.' }
        format.json { render json: { error: 'Acesso negado: Apenas compradores podem acessar esta página.' }, status: :forbidden }
      end
    end
  end

  def order_params
    params.require(:order).permit(:store_id, :buyer_id, order_items_attributes: [:id, :product_id, :amount, :price, :_destroy]).reject { |_, attributes| attributes['_destroy'] == 'true' }
  end
end