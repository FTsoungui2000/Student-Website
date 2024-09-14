class UsersController < ApplicationController
    before_action :redirect_if_authenticated, only: [:create, :new]

    def create
        @user = User.new(create_user_params)
        if @user.save
            @user.send_confirmation_email!
        else
            render :new, :status: :unprocessable_entity
        end
    end

    def destroy
        current_user.destroy
        reset_session
        redirect_to root_path, notice: "Your account has been deleted."
    end

    def edit
        @user = current_user
        @active_sessions = @user.active_sessions.order(created_at: :desc)
    end

    def new
        @user = User.new
    end

    def authenticate_user!
        redirect_to login_path, alert: "You need to login to access that page." unless user_signed_in?
    end

    def update
        @user = current_user
        @active_sessions = @user.active_sessions.order(created_at: :desc)
        if @user.authentication(params[:user][:surrent_password])
            if @user.update(update_user_params)
                if params[:user][:unconfirmed_email].present?
                    @user.send_confirmation_email!
                    redirect_to root_path, notice: "Check your email for confirmation instructions."
                else
                    redirect_to root_path, notice: "Account updated."
                end
            else
                render :edit, status: :unprocessable_entity
            end
        else
            flash.now[:error] = "Incorrect password"
            render :edit, status: :unprocessable_entity
        end
    end

    private

    def create_user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
    end

    def update_user_params
        params.require(:user).permit(:current_password, :password, :password_confirmation, :unconfirmed_email)

end
