require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:cowboy)
    @non_admin = users(:braile)
    @unactivated_user = users(:unactivated)
  end
  
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'destroy'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end
  
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "unactivated users do not display" do
    get users_path
    assert_select 'a[href=?]', user_path(@unactivated_user), count: 0
  end
  
  test "should not allow the viewing of unactivated users" do
    get user_path(@unactivated_user)
    assert_redirected_to root_url
    assert_not flash.empty?
  end
  
end
