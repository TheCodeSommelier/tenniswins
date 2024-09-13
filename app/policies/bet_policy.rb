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

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.admin? || user.premium?
        scope.all
      elsif user
        one_day_ago = Time.current.in_time_zone('UTC').beginning_of_day - 1.day
        scope.where('created_at < ?', one_day_ago)
      else
        scope.none
      end
    end
  end
end
