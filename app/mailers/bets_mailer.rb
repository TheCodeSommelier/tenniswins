class BetsMailer < ApplicationMailer
  def new_picks_email(user)
    @user = user
    @broadcast = true
    mail(
      to: Rails.env.production? ? @user.email : 'hello@tenniswins.com',
      subject: 'New picks arrived',
      message_stream: 'picks-notification'
    ) do |format|
      format.html { render 'new_picks_email' }
    end
  end
end
