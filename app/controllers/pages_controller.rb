class PagesController < ApplicationController
  def home; end

  def coming_soon
    @user = User.new
  end

  def membership; end

  def contact; end

  def cookie_consent; end
end
