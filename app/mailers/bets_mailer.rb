class BetsMailer < ApplicationMailer
  def send_picks(bets_ids)
    premium_user_emails = User.where('premium = ? OR credits > ?', true, 0).select(:email)
    @bets = Bet.where(id: bets_ids).includes(:match)
                                   .order(created_at: :desc)
                                   .group_by { |bet| bet.parlay_group || bet.id }
                                   .values

    premium_user_emails.each do |email|
      mail(
        to: Rails.env.production? ? email : 'hello@tenniswins.com',
        subject: 'Picks and parlays of the day',
        message_stream: 'outbound'
      )
    end
  end
end
