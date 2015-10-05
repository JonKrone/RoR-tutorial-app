require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  
  def setup
    @base_title = "Our Own Little Worlds"
  end
  
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "Home | OOLWs: #{@base_title}"
  end

  test "should get help" do
    get :help
    assert_response :success
    assert_select "title", "Help | OOLWs: #{@base_title}"
  end
  
  test "should get about" do
    get :about
    assert_response :success
    assert_select "title", "About | OOLWs: #{@base_title}"
  end
  
  test "should get contact" do
    get :contact
    assert_response :success
    assert_select "title", "Contact | OOLWs: #{@base_title}"
  end
end




=begin
I had been coding with pascal (SCAR, what else) for about 5 years When I took my
first java class. C++ was a pre-req so I hadn't considered it the first year but
by 10th grade, I really wanted to code more so I asked the teacher if I could
jump through C++ to java. This little customization to something I thought was
so entrenched

=end