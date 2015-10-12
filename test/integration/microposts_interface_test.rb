require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  
  def setup
    @user = users(:cowboy)
  end
  
  test "micropost interface" do
    log_in_as @user
    get root_path
    assert_select 'div.pagination' # paginated list in the home page?
    assert_select 'input[type=file]' # Test for file upload field
    
    # Invalid submission
    post microposts_path, micropost: { content: "" }
    assert_select 'div#error_explanation'
    
    # Valid submission
    content = "Two stones in a ferry"
    picture = fixture_file_upload('test/fixtures/Web.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content, picture: picture }
    end
    assert assigns(:micropost).picture?
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
  
  test "micropost sidebar count" do
    log_in_as @user
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    
    # User with zero microposts
    other_user = users(:mallory)
    log_in_as other_user
    get root_path
    assert_match "0 microposts", response.body
    
    # User with 1 micropost
    other_user.microposts.create!( content: "Mikey the micropost." )
    get root_path
    assert_match "1 micropost", response.body
  end
  
end
