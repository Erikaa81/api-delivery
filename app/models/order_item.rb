class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :price, presence: true
  validate :store_product

  private
  def order_params
    params.require(:order).permit(:store_id, :buyer_id, order_items_attributes: [:product_id, :quantity, :price])
  end
  
  def store_product
    return unless product && order # Verifica se tanto product quanto order estão presentes
  
    if product.store != order.store
      errors.add(:product, "product should belong to 'Store': #{order.store.name}")
    end
  end
end
