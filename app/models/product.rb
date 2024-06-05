class Product < ApplicationRecord
  belongs_to :store
  has_one_attached :image
  scope :not_deleted, -> { where(deleted: false) }
  has_many :order_items
  has_many :orders, through: :order_items
  
  validates :title, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(deleted: false) }
  scope :deleted, -> { where(deleted: true) }

  def soft_delete
    update(deleted: true)
  end

  def undelete
    update(deleted: false)
  end
  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(image, host: "localhost:3000") if image.attached?
  end
end