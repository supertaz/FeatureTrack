class UsersController < ApplicationController
  before_filter :require_user

  def show
    if current_user
      request.format = :html
      @user = current_user
    else
      redirect_to login_url
    end
  end

  def edit
    if current_user
      request.format = :html
      @user = current_user
    else
      redirect_to login_url
    end
  end

  def update
    if current_user
      @user = current_user
      if @user.update_attributes(params[:user])
        request.format = :html
        flash[:notice] = "Successfully updated user."
        redirect_to user_url
      else
        request.format = :html
        flash.now[:error] = "Account not updated, please correct the #{ActionController::Base.helpers.pluralize @user.errors.count, 'error'} below."
        render :action => 'edit'
      end
    else
      redirect_to login_url
    end
  end

end
