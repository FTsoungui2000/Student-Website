class ConfirmationsController < ApplicationController

    # Resends confirmation instructions for inconfirmed users
    def create
        @user = User.find_by(email: params[:user][:email].downcase)

        if @user.present? && @user.unconfirmed?
            @user.send_confirmation_email!
        else
            redirect_to new_confirmation_path, alert: "We could not find a user with that email or that email has already been confirmed."
        end
    end

    # Used to confirm users. Using confirmation tokens because they can't be guessed or tampered with
    def edit
        # find_signed gives us the safety that only allows the user to access the information within a sertain time period
        # The purpose allows us to further restrict the use of the signed id to just the confirmation of an email
        @user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)

        if @user.present?
            @user.confirm!
            redirect_to root_path, notice: "Younr account has been confirmed."
        else
            redirect_to new_confirmation_path, alert: "Invalid token"
        end
    end

    def new
        @user = User.new
    end
end
