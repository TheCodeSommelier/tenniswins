# frozen_string_literal: true

Premailer::Rails.config.merge!(
  preserve_styles: true,
  remove_ids: true,
  css_to_attributes: true
)
