module TasksHelper
  def monthsday(year, month)
    case month
    when 1, 3, 5, 7, 8, 10, 12
      31
    when 4, 6, 9, 11
      30
    when 2
      if year % 4 == 0
        29
      else
        28
      end 
    else
      0 
    end 
  end

  def total_per_day_of_week
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

  def total_per_day_of_month
    # データがない日にちにamount = 0を入れる
    @graphdata = []
    @graphdata_max = 0 
    i = 30 
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

  def total_per_month_of_year
    date = Date.today
    year = date.year
    month = date.month
    day = date.day
    day_max = monthsday(year, month)
 
    # データがない日にちにamount = 0を入れる
    @graphdata = []
    @graphdata_max = 0 
    i = 12 
    while(i > 0)
      if month == 1
        year -= 1
        month = 12
      else
        month -= 1
      end
      day_max = monthsday(year, month)
      time_per_month = Task.where(user_id: current_user.id, :date => "#{year}-#{month}-1".."#{year}-#{month}-#{day_max}").sum(:amount)
      @graphdata[i - 1] = [ "#{year}/#{month}/#{day}", time_per_month ]
      @graphdata_max = time_per_month if @graphdata_max < time_per_month 
      i -= 1
    end
  end

  def compare_with_the_past
    # 今までの合計
    user = current_user
    total = user.tasks.sum(:amount)
    # 一週間前、一ヶ月前、一年前と比較？
    i = 6
    sum_week = 0
    while(i >= 0)
      taskdata = Task.where(user_id: current_user.id, date: Date.today.days_ago(i))
      if !(taskdata == [])
        taskdata.each do |data|
          sum_week  = sum_week + data.amount
        end
      end
      i -= 1
    end
    total_week_ago = total - sum_week

    # 一ヶ月
    i = 30
    sum_month = 0
    while(i >= 0)
      taskdata = Task.where(user_id: current_user.id, date: Date.today.days_ago(i))
      if !(taskdata == [])
        taskdata.each do |data|
          sum_month  = sum_month + data.amount
        end
      end
      i -= 1
    end                                                                                                                                       
    total_month_ago = total - sum_month

    # 一年
    date = Date.today
    year = date.year
    month = date.month + 1
    day = date.day
    day_max = monthsday(year, month)

    i = 12
    sum_year = 0
    while(i > 0)
      if month == 1
        year -= 1
        month = 12
      else
        month -= 1
      end
      day_max = monthsday(year, month)
      puts("#{month}月 #{Task.where(user_id: current_user.id, :date => "#{year}-#{month}-1".."#{year}-#{month}-#{day_max}").sum(:amount)}時間")
      sum_year = sum_year + Task.where(user_id: current_user.id, :date => "#{year}-#{month}-1".."#{year}-#{month}-#{day_max}").sum(:amount)
      i -= 1
    end
    total_year_ago = total - sum_year

    # グラフデータ
    @graphdata = [ [ "一年前", total_year_ago ], ["一ヶ月前", total_month_ago], ["一週間前", total_week_ago], ["現在", total] ]
    @graphdata_max = total
  end
end
