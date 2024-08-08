class UserMailer < ApplicationMailer
  default from: User::MAILER_FROM_EMAIL

  def confirmation
    @user = user
    @confirmation_token = confirmation_token

    mail to: @user.email, subject: "Confirmation Instructions"
  end
end
