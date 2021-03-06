class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
  #
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    
    unless @user.activated?
      redirect_to root_url
      flash[:warning] = "You must be logged in to view profiles."
      return
    end
  end

  # Creates a new User.
  def new
    @user = User.new
  end

  # Creates a new User, logging in on a success.
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email #{@user.email} to activate your world"
      redirect_to root_url
    else
      render 'new'
    end
  end
  
  # Called upon a request for all users.
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  # Called upon a request to edit the page.
  def edit
    @user = User.find(params[:id])
  end
  
  # Update the User's parameters.
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "World updated"
      redirect_to @user #equiv: redirect_to user_url(@user)
    else
      render 'edit'
    end
  end
  
  # Deletes a User.
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "World removed"
    redirect_to users_url
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private
    
    # Strips params of anything we do do not expect
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    
    # BEFORE FILTERS
    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    # Confirms the correct user
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user? @user
    end
    
end
