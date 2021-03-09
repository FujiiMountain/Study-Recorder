class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "パスワード再設定用のメールを送りました。"
      redirect_to new_user_url
    else
      flash[:danger] = "メールアドレスが見つかりませんでした。"
      redirect_to new_password_reset_url
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      flash[:danger] = "パスワードを入力してください。"
      redirect_to edit_password_reset_url(params[:id], email: params[:email])
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "パスワードを変更しました。"
      redirect_to tasks_url
    else
      flash[:danger] = "エラーがあります。"
      redirect_to edit_password_reset_url(params[:id], email: params[:email])
    end
  end

  private
    
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to login_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "期限切れです。\nパスワードを変更したい場合再度同じ手順で変更手続きを行ってください。"
        redirect_to new_password_reset_url
      end
    end
end
