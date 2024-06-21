class PaymentsController < ApplicationController
    before_action :set_order, only: [:create]
  
    def create
      payment_params = {
        order_id: @order.id,
        value: payment_value,
        number: params[:number],
        valid: params[:valid],
        cvv: params[:cvv].to_i
      }
  
      if @order.update(status: 'processing_payment')
        PaymentJob.perform_later(payment_params)
  
        respond_to do |format|
          format.html { redirect_to @order, notice: 'Pagamento iniciado com sucesso.' }
          format.json { render json: @order, status: :accepted }
        end
      else
        respond_to do |format|
          format.html { redirect_to @order, alert: 'Erro ao iniciar o pagamento.' }
          format.json { render json: { errors: @order.errors }, status: :unprocessable_entity }
        end
      end
    end
  
    private
  
    def set_order
      @order = Order.find(params[:order_id])
    end
  
    def payment_value
      @order.total_price
    end
  end