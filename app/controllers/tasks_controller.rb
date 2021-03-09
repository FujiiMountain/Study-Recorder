class TasksController < ApplicationController
  include TasksHelper
  before_action :logged_in_user
  before_action :correct_user, only: [:destroy]

  def index
    date = Date.today
    year = date.year
    month = date.month
    day = date.day
    day_max = monthsday(year, month)

    @user_tasks = Task.where(user_id: current_user.id, :date => "#{year}-#{month}-1".."#{year}-#{month}-#{day_max}")
    
    # データがない日にちにamount = 0を入れる
    @graphdata = []
    @graphdata_max = 0
    i = 7
    while(i > 0)
      sum = 0
      taskdata = Task.where(user_id: current_user.id, date: Date.today.days_ago(i))
      if !(taskdata == [])
        taskdata.each do |data|
          sum = sum + data.amount
        end
      end
      @graphdata.push( [ Date.today.days_ago(i).strftime("%m/%d"), sum ] )
      @graphdata_max = sum if @graphdata_max < sum
      i -= 1
    end
  end

  def new
    @task = current_user.tasks.build(date: params[:date])
    @tasks = Task.where(user_id: current_user.id, date: params[:date]).page(params[:page]).per(5)
  end

  def create
    flug = 0
    @task = current_user.tasks.build(task_params)
    # @task.dateがnilの場合elseへ
    if @task.date
      year = @task.date.year
      month = @task.date.month
      day = @task.date.day

      # 月ごとの最大日にちをday_maxに格納
      day_max = monthsday(year, month)

      if day > day_max || day < 0 || day_max == 0
        flug = 1
      end
    else
      flug = 1
    end

    if flug == 0 && @task.save
      flash[:success] = "登録しました。"
      redirect_to tasks_url
    else
      flash[:danger] = "エラーがあります。"
      redirect_to new_task_url(date: @task.date)
    end
  end

  def edit
    @task = current_user.tasks.find(params[:id])
  end

  def update
    @task = current_user.tasks.find(params[:id])
    
    if @task.update_attributes(task_params)
      flash[:success] = "更新しました"
      redirect_to edit_task_path(@task)
    else
      flash[:danger] = "エラーがあります"
      redirect_to edit_task_path(@task)
    end
  end

  def show
    @tasks = current_user.tasks.page(params[:page]).per(5)
  end

  def destroy
    task = current_user.tasks.find(params[:id])
    date = task.date
    task.destroy
    flash[:success] = "削除しました。"
    redirect_back(fallback_location: root_path)
  end

  private

    def task_params
      params.require(:task).permit(:name, :amount, :date)
    end

    def correct_user
      @task = current_user.tasks.find_by(id: params[:id])
      redirect_to(root_url) if @task.nil?
    end
end
