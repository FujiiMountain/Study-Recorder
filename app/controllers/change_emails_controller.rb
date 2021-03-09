class ChangeEmailsController < ApplicationController
  def new
    @user = current_user
  end

  def create
    @user = current_user
    @change_email = params[:change_email][:email]
    if @change_email.match(/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/)
      if !(User.find_by(email: @change_email))#メールアドレスに重複がない
        @user.create_change_digest
        UserMailer.change_email(@user, @change_email).deliver_now
        flash[:info] = "パスワード変更用のメールを送りました。"
        redirect_to edit_user_url(current_user)
      else
        flash[:danger] = "メールアドレスが登録されています。"
        redirect_to new_change_email_url
      end
    else
      flash[:danger] = "エラーがあります。"
      redirect_to new_change_email_url
    end
  end

  def edit
    user = User.find_by(email: params[:email])
    if user.change_email_expired?
      flash[:danger] = "期限切れです。\nメールアドレスの変更がしたい場合再度同じ手続きで変更手順を行ってください。"
    else
      if user && user.activated && current_user?(user) && user.authenticated?(:change, params[:id])
        user.update_attribute(:email, params[:change_email])
        flash[:success] = "変更しました。"
      else
        flash[:danger] = "エラーがあります。"
      end
    end
    redirect_to edit_user_url(user)
  end
end
