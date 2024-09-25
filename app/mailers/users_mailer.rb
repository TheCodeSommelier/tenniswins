class UsersMailer < ApplicationMailer
  def welcome_new_user(user)
    email = user.email
    @name = user.first_name

    mail(
      to: Rails.env.production? ? email : 'hello@tenniswins.com',
      subject: "Welcome to Tennis Wins! 🎾 Let's Ace Those Bets!"
    )
  end

  def send_reciept(user, invoice_id)
    email = user.email
    @name = user.first_name

    invoice = Stripe::Invoice.retrieve(invoice_id)
    @invoice_pdf_link = invoice.invoice_pdf

    mail(
      to: Rails.env.production? ? email : 'hello@tenniswins.com',
      subject: 'Your Invoice is All Set, Champ! 🎉'
    )
  end

  def send_goodbye(user)
    email = user.email
    @name = user.first_name

    mail(
      to: Rails.env.production? ? email : 'hello@tenniswins.com',
      subject: "Farewell, #{@name} - Until We Meet Again!"
    )
  end
end
