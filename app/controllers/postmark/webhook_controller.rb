class Postmark::WebhookController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def handle_webhook
    data = JSON.parse(request.body.read)
    user_email = data['Email'] || data['Recipient']
    sub_change = data['RecordType'] == 'SubscriptionChange' && data['SuppressSending'] == true
    bounced = data['RecordType'] == 'Bounce' && data['Type'] == 'HardBounce'
    spam_complaint = data['RecordType'] == 'SpamComplaint'

    unsub_user(user_email) if sub_change || bounced || spam_complaint

    head :ok
  end

  private

  def unsub_user(email)
    email_exists = User.exists?(email:)

    if email_exists
      User.find_by(email:).update(email_sub: false)
    else
      Rails.logger.error "🔥 Email not found => #{email}"
    end
  end
end
