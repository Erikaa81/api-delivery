class BuyersController < ApplicationController
  skip_forgery_protection only: [:create, :update, :destroy]
  before_action :authenticate!
  before_action :set_buyer, only: %i[show edit update destroy]
  rescue_from User::InvalidToken, with: :not_authorized
  before_action :authorize_buyer, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.admin?
      @buyers = Buyer.includes(:user).all
    else
      @buyers = [current_user.buyer]
    end
  end

  def show
  end

  def profile
    @buyer = current_user.buyer
    render json: @buyer.to_json(include: :user)
  end

  def new
    @buyer = Buyer.new
    @buyers = User.where(role: :buyer) if current_user.admin?
  end

  def edit
  end

  def create
    @buyer = Buyer.new(buyer_params)
    @buyer.user = current_user unless current_user.admin?

    respond_to do |format|
      if @buyer.save
        format.html { redirect_to buyer_url(@buyer), notice: 'Comprador criado com sucesso.' }
        format.json { render :show, status: :created, location: @buyer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @buyer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @buyer.user.update(user_params)
        format.json { render json: @buyer.as_json(include: :user), status: :ok }
        format.html { redirect_to @buyer, notice: 'Comprador atualizado com sucesso.' }
      else
        format.json { render json: @buyer.errors, status: :unprocessable_entity }
        format.html { render :edit }
      end
    end
  end
  def destroy
    @buyer.destroy
    redirect_to buyers_url, notice: 'Comprador excluído com sucesso.'
  end

  def toggle_activation
    @buyer = Buyer.find(params[:id])
    if @buyer.user.active?
      @buyer.user.update(active: false)
    else
      @buyer.user.update(active: true)
    end
    redirect_to buyers_url
  end

  private

 
  def set_buyer
    @buyer = params[:id] ? Buyer.find(params[:id]) : current_user.buyer
  end

  def buyer_params
    params.require(:buyer).permit(
      :user_id,
      user_attributes: [:name, :id, :email, :password, :password_confirmation]
    )
  end

  def user_params
    params.require(:buyer).require(:user_attributes).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def authorize_buyer
    unless current_user.admin? || current_user == @buyer.user
      redirect_to buyers_url, alert: 'Você não tem permissão para acessar este comprador.'
    end
  end
end
