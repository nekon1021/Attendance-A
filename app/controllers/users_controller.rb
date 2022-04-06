require 'csv'
class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  before_action :set_one_month, only: :show
  before_action :admin_or_correct_user, only: :show

  def index
    @users = User.all
    @users = User.paginate(page: params[:page])
    @users = @users.where('name LIKE ?', "%#{params[:search]}%") if params[:search].present?
  end
  

  def show
    respond_to do |format|
      format.html {
        @worked_sum = @attendances.where.not(started_at: nil).count
      }
      format.csv
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end

  def edit_basic_info
    @user = User.find(params[:id])
  end

  def update_basic_info
    if @user.update_attributes(basic_info_params)
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end
  
  def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "閲覧権限がありません。"
        redirect_to(root_url)
      end
  end
  
  def change_log
    @attendances = load_attendances
    if request.xhr?
      render '_change_logs', layout: false
    else
      render
    end
  end
  
  private
  
    def load_attendances
      @first_day = params[:y] && params[:m] ?
        Date.new(params[:y].to_i, params[:m].to_i, 1) : Date.current.beginning_of_month
      @last_day = @first_day.end_of_month
      current_user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end
  
    def user_params
      params.require(:user).permit(:name, :email, :department, :password, :password_confirmation)
    end

    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
end