class User < ApplicationRecord
  has_many :tasks, :dependent => :destroy

  attr_accessor :remember_token, :activation_token, :reset_token, :change_token
  before_save :downcase_email
  before_create :create_activation_digest

  has_secure_password
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/
  VALID_PW_REGEX = /((\d+[a-zA-Z]+)|([a-zA-Z]+\d+))(\d*[a-zA-Z]*)*/
  validates :name, presence: true
  validates :email, presence: true, format: VALID_EMAIL_REGEX, uniqueness: true
  validates :password, presence: true, length: { in: 6..20 }, format: VALID_PW_REGEX, allow_blank: true

  def self.digest(string)
    cost = BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_attribute(:activated, true)
    update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 10.minutes.ago
  end

  def create_change_digest
    self.change_token = User.new_token
    update_attribute(:change_digest, User.digest(change_token))
    update_attribute(:change_sent_at, Time.zone.now)
  end

# ユーザのメールアドレスと変更予定のメールアドレスの情報をメール内リンクのクエリ中に入れるため
# change_emailsコントローラ内で引数を増やして呼び出している
=begin
  def send_change_email
    UserMailer.change_email(self).deliver_now
  end
=end

  def change_email_expired?
    change_sent_at < 10.minutes.ago
  end

  private

    def downcase_email
      self.email = self.email.downcase
    end

    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
