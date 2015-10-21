class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: "Relationship",
                                  foreign_key: "follower_id",
                                  dependent: :destroy
  has_many :passive_relationships, class_name: "Relationship",
                                   foreign_key: "followed_id",
                                   dependent: :destroy
  #由于使用followeds不符合语言习惯，因此，使用source参数将其该复数形式改为following                                   
  #followers符合语言习惯，故不用更改
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships

	#增加虚拟属性
  attr_accessor :remember_token, :activation_token, :reset_token

	before_save { self.email = email.downcase}
  before_create :create_activation_digest

	validates :name, presence: true, length:{maximum:50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length:{maximum:255},
						format: {with: VALID_EMAIL_REGEX},
						uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }, allow_blank: true
	# validates :password_confirmation, length: { minimum: 6 }

  # 返回指定字符串的哈希摘要
	def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # 返回一个随机令牌
  def User.new_token
  	SecureRandom.urlsafe_base64
  end

  # 为了持久会话，在数据库中记住用户
  def remember
  	self.remember_token = User.new_token
  	update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 忘记用户
  def forget
  	update_attribute(:remember_digest, nil)
  end

  def authenticated?(attribute,token)
    digest = send("#{attribute}_digest")
  	return false if digest.nil?
  	BCrypt::Password.new(digest).is_password?(token)
  end

  # 激活账户
  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # 发送激活邮件
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #设置密码重置相关属性
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  #发送密码重设邮件
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  #如果密码重设超时失效了， 返回true
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  def feed
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", 
    #                 following_ids: following_ids, user_id: id)
    following_ids = "SELECT  followed_id  FROM  relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                      OR user_id = :user_id", user_id: id)
  end

  #follows a user.
  def follow(other_user)
    active_relationships.create(followed_id: other_user.id)
  end

  #unfollows a user.
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  #reture tru if the current user is following the other user.
  def following?(other_user)
    following.include?(other_user)
  end

  private

    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
