class StoresController < ApplicationController
  skip_forgery_protection only: [:create, :update, :destroy]
  before_action :authenticate!, except: [:products] 
  before_action :set_store, only: %i[show edit update destroy]
  rescue_from User::InvalidToken, with: :not_authorized
  include ActionController::Live

  def index
    if current_user.present?
      if current_user.admin?
        @stores = Store.all
      else
        @stores = current_user.stores
      end
      respond_to do |format|
        format.html
        format.json { render json: @stores.map { |store| store.as_json(methods: :image_url) } }
      end
    else
      render json: { error: "Você deve estar logado para visualizar esta página." }, status: :unauthorized
    end
  end
  
  def show
    @store = Store.find(params[:id])
    respond_to do |format|
      format.html 
      format.json { render json: @store.as_json(methods: :image_url) }
    end
  end

  def new
    @store = Store.new
    @sellers = User.where(role: :seller) if current_user.admin?
  end

  def edit
    @sellers = User.where(role: :seller) if current_user.admin?
  end

  def create
    @store = Store.new(store_params)
    @store.user = current_user unless current_user.admin?

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: "Loja criada com sucesso." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @store.update(store_params)
      @store.image.attach(params[:store][:image]) if params[:store][:image].present?
      render json: @store.as_json(methods: :image_url), status: :ok
    else
      render json: @store.errors, status: :unprocessable_entity
    end
  end

  def destroy
    if @store.soft_delete
      respond_to do |format|
        format.html { redirect_to stores_url, notice: "Loja excluída com sucesso." }
        format.json { render json: { message: "Loja excluída com sucesso." }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to stores_url, alert: "Falha ao excluir loja." }
        format.json { render json: { error: "Falha ao excluir loja." }, status: :unprocessable_entity }
      end
    end
  end

  def toggle_activation
    @store = Store.find(params[:id])
    if @store.active
      @store.update(active: false)
      flash[:notice] = "Loja desativada com sucesso."
    else
      @store.update(active: true)
      flash[:notice] = "Loja ativada com sucesso."
    end
    redirect_to stores_url
  end
  
  def products
    @store = Store.find(params[:id])
    @products = @store.products

    respond_to do |format|
      format.json { render json: @products }
    end
  end

  def new_order 
    response.headers["Content-Type"] = "text/event-stream"
    sse = SSE.new(response.stream, retry: 300, event: "waiting-orders")

    EventMachine.run do 
      periodic_timer = EventMachine::PeriodicTimer.new(3) do
      order = Order.where(store_id: params[:id], state: :created).last
      if order 
        message = { time: Time.now, order: order }
        sse.write(message, event: "new-order")
      else
        sse.write({ time: Time.now }, event: "no")
      end
    end
  end

  rescue IOError, ActionController::Live::ClientDisconnected
    sse.close if sse 
  ensure
    sse.close if sse  
  end
end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    required = params.require(:store)
    if current_user.admin?
      required.permit(:name, :user_id)
    else
      required.permit(:name)
    end
  end

