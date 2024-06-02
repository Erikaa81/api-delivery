class BuyersController < ApplicationController
    skip_forgery_protection only: [:create, :update, :destroy]
    before_action :authenticate!
    before_action :set_buyer, only: %i[show edit update destroy]
    rescue_from User::InvalidToken, with: :not_authorized
  
    def index
      @buyers = Buyer.includes(:user).all  
    end
  
    def show
    end
  
    def new
      @buyer = Buyer.new
      @buyers = User.where(role: :buyer) if current_user.admin?
    end
  
    def edit
        @sbuyers = User.where(role: :buyer) if current_user.admin?
      end
  
      def create
        @buyer = Buyer.new(buyer_params)
        if current_user.admin?
          @buyer.user = User.new(user_params) if buyer_params[:user_attributes].present?
        else
          @buyer.user = current_user
        end
    
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
        @buyer = Buyer.find(params[:id]) 
        logger.debug "Buyer Params: #{buyer_params.inspect}"
        if @buyer.update(buyer_params)
            redirect_to buyers_url
        else
          render :edit
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
      @buyer = Buyer.find(params[:id])
    end
  
    def buyer_params
        params.require(:buyer).permit(
          :user_id,
          user_attributes: [:id, :email, :password, :password_confirmation]
        )
      end
      
      def user_params
        params.require(:buyer).require(:user_attributes).permit(:email, :password, :password_confirmation, :role)
      end
    end
  