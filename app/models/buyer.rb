class Buyer < ApplicationRecord
    belongs_to :user, optional: true
    accepts_nested_attributes_for :user
    validates :user, presence: true
    validate :user_must_be_buyer
    
    private
  
    def user_must_be_buyer
        return unless user
        
        errors.add(:user, 'must have role buyer') unless user.role == 'buyer'
      end
      
  end
