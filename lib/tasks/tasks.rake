# frozen_string_literal: true

namespace :bulk_ops do
  task reset_credits: :environment do
    User.update_all(credits: 0)
  end
end
