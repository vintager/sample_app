class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def edit
  end

  def create
  	@user = User.find_by(email: params[:password_reset][:email])
  	if @user
  		@user.create_reset_digest
  		@user.send_password_reset_email
  		flash[:info] = "Email sent with password reset instructins"
  		redirect_to root_url
  	else
  		flash[:danger] = "Email address not found"
  		render 'new'
  	end
  end

  def update
    # if both_passwords_blank?，这种用法有问题，英文版已更正
    if params[:user][:password].empty?
      flash.now[:danger] = "Password can't be blank."
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:sucess] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    #如果密码和密码确认都为空，返回true，这种用法有问题，英文版已更正
    # def both_passwords_blank?
    #   params[:user][:password].blank? &&
    #     params[:user][:password_confirmation].blank?
    # end
    #事前过滤器
    def get_user
      @user = User.find_by(email: params[:email])
    end

    #确保是有效用户
    def valid_user
      unless (@user && @user.activated? && 
                 @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    #检查重设令牌是否过期
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Passwrod reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
