class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :following, through: :active_relationships,  source: :followed
  has_many :followers, through: :passive_relationships
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest


  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: {maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  has_secure_password
  
  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    
  end
  
  # Forgets a user by removing a user's cookie digest.
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  # Returns true if the given attribute [:remember, :activation] digest matches
  # the corresponding token.
  def authenticated? (attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # Activates an account.
  def activate
    update_columns( activated: true, activated_at: Time.zone.now )
  end

  # Sends an activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  # Create a password reset digest.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns( reset_digest:  User.digest(reset_token),
                    reset_sent_at: Time.zone.now )
  end
  
  # Send a password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  # Returns whether our password reset token has expired or not.
  # Useful to read '<' as "earlier than" where our code can be read as:
  # "Password reset sent earlier than two hours ago"
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  # Defines a feed of microposts!
  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE  follower_ID = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                    OR user_id = :user_id", user_id: id)
  end
  
  # Follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end
  
  # Unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  # Returns true if self is following the other user.
  def following?(other_user)
    self.following.include?(other_user)
  end
  
  private 
    
    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
  
    class << self
      
      # Returns the hash digest of the given string.
      def digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                      BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
      end
      
      # Returns a random token
      def new_token
        SecureRandom.urlsafe_base64
      end
    end
  
end
