require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  
  test "full title helper" do
    assert_equal full_title,            "OOLWs: Our Own Little Worlds"
    assert_equal full_title("Sign up"), "Sign up | OOLWs: Our Own Little Worlds"
  end
end