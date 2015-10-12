require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  
  def setup
    @user = users(:cowboy)
  end
  
  test "micropost interface" do
    log_in_as @user
    get root_path
    assert_select 'div.pagination' # paginated list in the home page?
    
    # Invalid submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: "" }
    end
    assert_select 'div#error_explanation'
    
    # Valid submission
    content = "Two stones in a ferry"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    
    # Delete a post
    assert_select 'a', text: 'delete'
    first_mp = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_mp)
    end
    
    # See no delete options on another user's profile
    get user_path(users(:braile))
    assert_select 'a', text: 'delete', count: 0
  end
  
end
