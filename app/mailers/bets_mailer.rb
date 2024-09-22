class BetsMailer < ApplicationMailer
  def send_picks(bets_ids)
    premium_user_emails = User.all.select(:email)

    premium_user_emails.each do |email|
      mail(
        to: Rails.env.production? ? email : 'hello@tenniswins.com',
        subject: 'New picks and parlays have been added',
        message_stream: 'outbound'
      )
    end
  end
end
