class User < ApplicationRecord
  class InvalidToken < StandardError; end 

  enum :role, [:admin, :seller, :buyer]
  validates :role, presence: true
  validates :active, inclusion: { in: [true, false] }
  has_many :stores
  has_one :buyer
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  def deactivate!
    update(active: false)
  end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :buyer, dependent: :destroy
  validates :role, presence: true, inclusion: { in: %w[buyer seller admin] }
  after_save :create_buyer_if_needed
  before_save :set_name_from_email

  def password_required?
    new_record? || password.present?
  end

  def self.token_for(user)
    jwt_headers = {exp: 15.minute.from_now.to_i}
    payload = {id: user.id, email: user.email, role: user.role}
  
    JWT.encode payload.merge(jwt_headers), Rails.application.credentials.jwt_secret_key, "HS256"
  end

  def self.from_token(token)
    decoded = JWT.decode(
    token,  Rails.application.credentials.jwt_secret_key, true, {algorithm: "HS256"}
    )
    user_data = decoded[0].with_indifferent_access.except(:exp)
    User.new(user_data)
    
  rescue JWT::DecodeError => e
    Rails.logger.error "erro ao decodificar token JWT: #{e.message}"
    raise InvalidToken.new 

  end
end

private

def set_name_from_email
  self.name = email.split('@').first if name.blank? && email.present?
end

def create_buyer_if_needed
  if role == 'buyer' && buyer.nil?
    create_buyer
  end
end