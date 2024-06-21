class Order < ApplicationRecord
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :store
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  attribute :payment, :boolean, default: false

  accepts_nested_attributes_for :order_items, allow_destroy: true

  validate :buyer_role
  validates_associated :order_items
  validates :store_id, presence: true

  # Definindo as transições de estado
  state_machine initial: :created do
    event :accept do
      transition created: :accepted
    end
 
    event :approve_payment do
      transition accepted: :approved
    end

    state :created
    state :accepted
    state :approved
    state :payment_failed
  end

  private

  def buyer_role
    unless buyer&.buyer?
      errors.add(:buyer, "should be a 'buyer'")
    end
  end
end