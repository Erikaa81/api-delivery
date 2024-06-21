class PaymentJob < ApplicationJob
  queue_as :default

  def perform(order:, value:, number:, valid:, cvv:)
    params = { value: value, number: number, valid: valid, cvv: cvv }
    response = con.post("/payments", params.to_json)

    order = Order.find(order.id) 

    if response.success?
      order.approve_payment
      order.save
      Rails.logger.info "Payment processed successfully for order #{order.id}. Status updated to 'approved'."
    else
      order.update(status: 'payment_failed')
      Rails.logger.info "Payment failed for order #{order.id}. Status updated to 'payment_failed'."
    end
  end

  private
  
  def config
    Rails.configuration.payment
  end
  
  def con
    @con ||= Faraday.new(
      url: config.host,
      headers: {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
      }
    )
  end
end