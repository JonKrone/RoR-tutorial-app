require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  test "invalid new user does not create new user" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "", email: "user@invalid.com",
                               password: "foo", password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end
  
  test "Valid signup results in new user" do
    get signup_path
    assert_difference 'User.count', 1 do
      post_via_redirect users_path, user: { name: "Test User",
                                           email: "test@users.com",
                                           password: "Fiddlestix",
                                           password_confirmation: "Fiddlestix" }
    end
    assert_template 'users/show'
  end
  
end