# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization

  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  rescue_from AbstractController::ActionNotFound, with: :skip_pundit? # This needed to be added in

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(root_path)
  end

  private

  def skip_pundit?
    is_devise_controller = devise_controller?
    is_admin_namespace = params[:controller] =~ /^(rails_)?admin/
    is_pages_controller = params[:controller] == 'pages'
    is_user_reg = params[:controller] == 'users/registrations'

    Rails.logger.debug("🔥 Checking skip_pundit? => Devise: #{is_devise_controller}, Admin: #{is_admin_namespace}, Pages: #{is_pages_controller}, User registraion: #{is_user_reg}")

    is_devise_controller || is_admin_namespace || is_pages_controller || is_user_reg
  end
end
