# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'info@tenniswins.com'
  layout 'mailer'
end
