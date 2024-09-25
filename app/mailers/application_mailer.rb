# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'hello@tenniswins.com',
          message_stream: 'outbound'
  layout 'mailer'

  helper Admin::BetsHelper
end
