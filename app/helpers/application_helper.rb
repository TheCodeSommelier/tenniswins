# frozen_string_literal: true

module ApplicationHelper
  def display_credits
    if current_user.premium
      '&infin'
    else
      current_user.credits
    end
  end
end
