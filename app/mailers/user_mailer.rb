class UserMailer < ApplicationMailer
  default from: 'fujiimountain223@gmail.com'

  def account_activation(user)
    @user = user
    mail(subject: '認証をお願いします', to: @user.email)
  end

  def password_reset(user)
    @user = user
    mail(subject: 'パスワード再設定', to: @user.email)
  end

  def change_email(user, change_email)
    @user = user
    @change_email = change_email
    mail(subject: "メールアドレス変更", to: @user.email)
  end
end
