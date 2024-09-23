# frozen_string_literal: true

class BetPolicy < ApplicationPolicy
  def index?
    user
  end

  def new?
    create?
  end

  def create?
    user.admin?
  end

  def edit?
    update?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def bet_won?
    user.admin?
  end

  def matches_autocomplete?
    true
  end

  def view_data?
    !record.won.nil? || user.admin? || user.premium? || user_has_unlocked_bet?
  end

  def data_should_be_visible?(bet)
    !bet.won.nil? || bet.created_at >= 1.day.ago
  end

  private

  def user_has_unlocked_bet?
    UserBet.where(user:, bet: record).exists?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end
end
