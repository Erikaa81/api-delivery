require 'rails_helper'

RSpec.describe "stores/new", type: :view do
  let(:user) {
    User.create!(
      email: "admin@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: :seller
    )
  }

  before(:each) do
    sign_in(user)
    @store = assign(:store, Store.new(
      name: "MyString"
    ))
  end

  it "renders new store form" do
    render

    assert_select "form[action=?][method=?]", stores_path, "post" do
      assert_select "input[name=?]", "store[name]"
    end
  end
end
