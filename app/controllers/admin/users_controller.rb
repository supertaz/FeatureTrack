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
    @user.active = true
    @user.source_api_keys.build
    @user.set_global_admin_override
  end

  def create
    @user = User.new(params[:user])
    @user.set_global_admin_override
    if @user.save
      flash[:notice] = 'Successfully added user.'
      redirect_to admin_users_url
    else
      render :action => 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    @user.set_global_admin_override
  end

  def update
    @user = User.find(params[:id])
    @user.set_global_admin_override
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
    @user.set_global_admin_override
    if @user.save
      flash[:notice] = "Successfully deactivated #{@user.email}."
    else
      flash[:error] = "Unable to deactivate #{@user.email}."
    end
    redirect_to admin_users_url
  end

  def activate
    @user = User.find(params[:id])
    @user.active = true
    @user.set_global_admin_override
    if @user.save
      flash[:notice] = "Successfully activated #{@user.email}."
    else
      flash[:error] = "Unable to activate #{@user.email}."
    end
    redirect_to admin_users_url
  end

end
