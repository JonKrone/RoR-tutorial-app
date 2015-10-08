require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @base_title = "Our Own Little Worlds"
  end
  
  test "should get signup" do
    get :signup
    assert_response :success
    assert_select "title", full_title("Sign up")
  end
end
