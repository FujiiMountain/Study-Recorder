class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin?, only: [:index, :show]

  def index
    @users = User.all.page(params[:page]).per(5)
  end

  def new
    @user = User.new(name: params[:name], email: params[:email])
    @error = session[:error]
    @errors_count = session[:errors_count]
    @have_error_name = session[:have_error_name]    
    @have_error_email = session[:have_error_email]    
    @have_error_password = session[:have_error_password]    
    @have_error_password_confirmation = session[:have_error_password_confirmation]    
    session.delete(:error)
    session.delete(:errors_count)
    session.delete(:have_error_name)
    session.delete(:have_error_email)
    session.delete(:have_error_password)
    session.delete(:have_error_password_confirmation)
  end

  def create
    @user = User.new(user_params)

    if @user.save
      @user.send_activation_email
      flash[:info] = "認証用のメールを送りました。"
      redirect_to root_url
    else
      session[:error] = !@user.valid?
      session[:errors_count] = @user.errors.messages.count
      session[:have_error_name] = @user.errors.full_messages_for(:name).first
      session[:have_error_email] = @user.errors.full_messages_for(:email).first
      session[:have_error_password] = @user.errors.full_messages_for(:password).first
      session[:have_error_password_confirmation] = @user.errors.full_messages_for(:password_confirmation).first
      redirect_to new_user_url(name: @user.name, email: @user.email)
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      flash[:success] = "更新しました。"
      redirect_to edit_user_url(@user)
    else
      flash[:danger] = "エラーがあります。"
      redirect_to edit_user_url(@user)
    end
  end

  def show
    @user = User.find(params[:id])
    @tasks = @user.tasks.where(user_id: @user.id).page(params[:page]).per(5)
  end

  def destroy
    user = User.find(params[:id])

    if current_user.admin || user == current_user
      if user.destroy
        flash[:success] = "#{user.name}を削除しました。"
        if current_user.admin && !(user == current_user)
          redirect_to users_url
        else
          redirect_to root_url
        end
      else
        flash[:danger] = "削除できませんでした。"
        redirect_to tasks_url
      end
    else
      flash[:danger] = "権限がありません。"
      redirect_to tasks_url
    end
  end

  private
    
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def admin?
    if !(current_user.admin == true)
      flash[:danger] = "権限がありません。"
      redirect_to tasks_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

end
