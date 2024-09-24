class UsersMailer < ApplicationMailer
  def welcome_new_user(user)
    email = user.email
    @name = user.first_name

    mail(
      to: Rails.env.production? ? email : 'hello@tenniswins.com',
      subject: "Welcome to Tennis Wins! 🎾 Let's Ace Those Bets!",
      message_stream: 'outbound'
    )
  end
end
