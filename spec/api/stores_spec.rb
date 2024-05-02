require "rails_helper"

RSpec.describe"/stores",type: :request do
   let(:user){
       user = User.new(
         email: "usuario@example.com",
         password:"123456", 
         password_confirmation: "123456",
         role: :seller        )
       user.save!
       user
      }
           
       let(:valid_attributes) {
         {name:"New Store", user: user}
       }
     
       let(:invalid_attributes) {
         {name:nil}
       }
       before{
         sign_in(user)
       }

       let(:credential) {Credential.create_access(:seller)}
       let(:signed_in) { api_sign_in(user, credential)}

      describe "GET /show" do
        it "renders a successful response with store data" do
          store = Store.create!(name: "New Store", user: user)
          get("/stores/#{store.id}",
            headers: {
              "Accept" => "application/json",
              "Authorization" => "Bearer #{signed_in["token"]}"
            }
          )
          json = JSON.parse(response.body)
      
          expect(json["name"]).to eq "New Store"
        end
      end
    end