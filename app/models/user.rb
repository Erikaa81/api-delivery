class User < ApplicationRecord
  class InvalidToken < StandardError; end 

  enum :role, [:admin, :seller, :buyer]
  has_many :stores
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def self.token_for(user)
    jwt_headers = {exp: 15.minute.from_now.to_i}
    payload = {id: user.id, email: user.email, role: user.role}
    JWT.encode(payload.merge(jwt_headers),"muito.secreto", "HS256")
  end

  def self.from_token(token)
    decoded = JWT.decode(
    token, "muito.secreto", true, {algorithm: "HS256"}
    )
    user_data = decoded[0].with_indifferent_access
    User.find(user_data[:id])
  rescue JWT::DecodeError => e
    Rails.logger.error "erro ao decodificar token JWT: #{e.message}"
    raise InvalidToken.new 
    
  end
end


  
    
