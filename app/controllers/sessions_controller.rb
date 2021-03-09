class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user = User.find_by(email: session_params[:email])
    if user && user.authenticate(session_params[:password])
      if user.activated?
        log_in(user)
        remember(user) if session_params[:remember_me] == "1"
        flash[:success] = "ログインしました。"
        redirect_back_or tasks_url
      else
        message = "アカウントが有効化できていません。"
        message += "メールを確認してアカウントを有効化してください。"
        flash[:warning] = message
        redirect_to login_url
      end
    else
      flash.now[:danger] = "メールアドレスまたはパスワードが間違っています。"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    message = "ログアウトしました。"
    flash[:info] = message
    redirect_to root_url
  end

  private

    def session_params
      params.require(:session).permit(:email, :password, :remember_me)
    end
end
