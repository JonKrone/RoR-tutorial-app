require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(name: "Test User", email: "test@user.com",
                    password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = "    "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "    "
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" * 247 + "@user.com"
  end
  
  test "email addresses should be saved downcase" do
    upcased_email = "ROGER@that.CoM"
    @user.email = upcased_email
    @user.save
    assert_equal upcased_email.downcase, @user.reload.email
  end
  
  test "email validation should accept valid addresses" do
    addresses = %w[USER@foo.com THE_US_ER@foo.BAR.org first.last@foo.jp
                  alice+bob@bar.ge]
    addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    addresses = %w[user@example,com user_at_foo.org user.name@example.
                  foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    for invalid_address in addresses
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  test "email addresses should be unique" do
    dup_user = @user.dup
    dup_user.email = @user.email.upcase
    @user.save
    assert_not dup_user.valid?
  end
  
  test "password should be nonblank" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end
  
  test "password should have minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should be false for a user with nil remember_digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed on destruction of a user" do
    @user.save
    @user.microposts.create!(content: "farts smell")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  test "should follow and unfollow a user" do
    cowboy = users(:cowboy)
    braile = users(:braile)
    assert_not braile.following?(cowboy) # check we are not following
    
    # Braile follows Cowboy
    braile.follow(cowboy)
    assert braile.following? cowboy
    assert cowboy.followers.include? braile
    
    # Cowboy unfollows Braile
    cowboy.unfollow braile
    assert_not cowboy.following? braile
  end
  
  test "feed should have the right posts" do
    cowboy = users(:cowboy)
    braile = users(:braile)
    lana   = users(:lana)
    
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert cowboy.feed.include?(post_following)
    end
    
    # Posts from self
    cowboy.microposts.each do |post_self|
      assert cowboy.feed.include?(post_self)
    end
    
    # Posts from unfollowed user
    cowboy.microposts.each do |post_unfollowed|
      assert_not braile.feed.include?(post_unfollowed)
    end
  end

end
