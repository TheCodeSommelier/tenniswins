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

  def bet_won?
    user.admin?
  end

  def matches_autocomplete?
    true
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.admin? || user.premium?
        scope.all
      elsif user
        scope.where('created_at < ?', Time.current.beginning_of_day - 2.days)
      else
        scope.none
      end
    end
  end
end
