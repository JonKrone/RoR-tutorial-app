require 'test_helper'

class RelationshipsControllerTest < ActionController::TestCase
  
  
  def setup
  end

  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post :create
    end
  end
  
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete :destroy, id: relationships(:one)
    end
    assert_redirected_to login_url
  end

end
