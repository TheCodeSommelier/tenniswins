class BetPolicy < ApplicationPolicy
  def index?
    user&.admin?
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
      user.admin? ? scope.all : scope.none
    end
  end
end
