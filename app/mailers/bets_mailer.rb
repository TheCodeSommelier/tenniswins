class BetsMailer < ApplicationMailer
  def send_picks(date)
    premium_user_emails = User.where(premium: true).select(:email)
    date_arr = date.split('-').map(&:to_i)
    formatted_date = Date.new(date_arr[0], date_arr[1], date_arr[2])

    start_of_day = formatted_date.beginning_of_day
    end_of_day = formatted_date.end_of_day

    @bets = Bet.where(created_at: start_of_day..end_of_day)
    premium_user_emails.each do |email|
      mail(
        to: Rails.env.production? ? 'info@tennis-winns.com' : email,
        subject: 'Tennis picks/parlays for the day',
        message_stream: 'outbound'
      )
    end
  end
end
