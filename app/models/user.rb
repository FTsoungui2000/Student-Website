class User < ApplicationRecord
    CONFIRMATION_TOKEN_EXPIRATION = 10.minutes

    has_secure_password

    before_save :downcase_email

    validates :email, format: {with:URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true

    # Sends email from UserNailer
    MAILER_FROM_EMAIL = "no-reply@example.com"

    def confirm!
        update_colums(confirmed_at: Time.current)
    end

    def confirmed?
        confirmed_at.present?
    end

    def generate_confirmation_token
        signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, pyrpose: :confirm_email
    end

    def unconfirmed?
        !confirmed?
    end

    # Creates a new confirmation token, which is then sends a link (that expires and can't be reused) to the users email
    def send_confirmation_email!
        confirmation_token = generate_confirmation_token
        UserMailer.confirmation(self, confirmation_token).devliver_now
    end
    
    private

    def downcase_email
        self.email = email.downcase
    end
end
