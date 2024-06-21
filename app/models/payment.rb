class Payment < ApplicationRecord
    belongs_to :order
  
    validates :transaction_id, :status, presence: true
  end
  