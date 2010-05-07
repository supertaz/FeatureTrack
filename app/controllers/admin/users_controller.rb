class Admin::UsersController < ApplicationController
  before_filter :require_global_admin

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'Successfully added user.'
      redirect_to admin_users_url
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:notice] = 'Successfully updated user.'
      redirect_to admin_users_url
    else
      render :action => 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.active = false
    @user.save
    flash[:notice] = "Successfully deactivated #{@user.email}."
    redirect_to admin_users_url
  end

  def activate
    @user = User.find(params[:id])
    @user.active = true
    @user.save
    flash[:notice] = "Successfully activated #{@user.email}."
    redirect_to admin_users_url
  end

end
