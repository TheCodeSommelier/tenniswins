# frozen_string_literal: true

namespace :bulk_ops do
  task reset_credits_subs: :environment do
    User.update_all(credits: 0, premium: false)
  end
end
