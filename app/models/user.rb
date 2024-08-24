class User < ApplicationRecord
    CONFIRMATION_TOKEN_EXPIRATION = 10.minutes

    has_secure_password
    has_secure_token :remember_token

    attr_accessor :current_password

    before_save :downcase_email
    before_save :downcase_unconfirmed_email

    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, presence: true, uniqueness: true
    validates :unconfirmed_email, format: {with: URI::MailTo::EMAIL_REGEXP, allow_blank: true}

    # Sends email from UserMailer
    MAILER_FROM_EMAIL = "no-reply@example.com"

    PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes

    def confirm!
        if unconfirmed_or_reconfirming?
            if unconfirmed_email.present?
                return false unless update(email: unconfirmed_email, unconfirmed_email: nil)
            end
            update_colums(confirmed_at: Time.current)
        else
            false
        end
    end

    def confirmed?
        confirmed_at.present?
    end

    def confirmable_email
        if unconfirmed_email.present?
            unconfirmed_email
        else
            email
        end
    end

    def generate_confirmation_token
        signed_id expires_in: CONFIRMATION_TOKEN_EXPIRATION, pyrpose: :confirm_email
    end

    def unconfirmed?
        !confirmed?
    end

    def generate_password_reset_token
        signed_id expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password
    end

    def reconfirming?
        unconfirmed_email.present?
    end

    def unconfirmed_or_reconfirming?
        unconfirmed? || reconfirming?
    end

    # Creates a new confirmation token, which is then sends a link (that expires and can't be reused) to the users email
    def send_confirmation_email!
        confirmation_token = generate_confirmation_token
        UserMailer.confirmation(self, confirmation_token).devliver_now
    end
    
    def send_password_reset_email!
        password_reset_token = generate_password_reset_token
        UserMailer.password_reset(self, password_reset_token).devliver_now
    end
    
    private

    def downcase_email
        self.email = email.downcase
    end

    def downcase_unconfirmed_email
        return if unconfirmed_email.nil?
        self.unconfirmed_email = unconfirmed_email.downcase
    end
    
end
