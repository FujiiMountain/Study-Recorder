class GraphsController < ApplicationController
  include TasksHelper

  def new
  end

  def create
  end

  def show
    case params[:id]
    when "1"
      total_per_day_of_week
    when "2"
      total_per_day_of_month
    when "3"
      total_per_month_of_year
    when "4"
      compare_with_the_past
    end
    render "tasks/index"
  end
end
