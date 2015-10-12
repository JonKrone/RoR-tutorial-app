require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:cowboy)
    @micropost = @user.microposts.build( content: "Farts smell" )
  end
  
  test "micropost should be valid" do
    assert @micropost.valid?
  end
  
  test "user id should be present in a micropost" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  test "microposts need content" do
    @micropost.content = '    '
    assert_not @micropost.valid?
  end
  
  test "content can be at max only 140 characters" do
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end
  
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
  
end
