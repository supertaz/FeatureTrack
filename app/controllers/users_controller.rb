class UsersController < ApplicationController
  before_filter :require_user

  def show
    if current_user
      @user = current_user
    else
      redirect_to login_url
    end
  end

  def edit
    if current_user
      @user = current_user
    else
      redirect_to login_url
    end
  end

  def update
    if current_user
      @user = current_user
      if @user.update_attributes(params[:user])
        flash[:notice] = "Successfully updated user."
        redirect_to user_url
      else
        render :action => 'edit'
      end
    else
      redirect_to login_url
    end
  end

end
