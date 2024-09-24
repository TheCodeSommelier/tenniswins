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
    not_nil_won? || user_has_access?
  end

  private

  def not_nil_won?
    !record.won.nil?
  end

  def user_has_access?
    user.admin? || user.premium? || user_has_unlocked_bet?
  end

  # Checks if the user has unlocked the bet
  def user_has_unlocked_bet?
    UserBet.where(user: user, bet: record).exists?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end
end
