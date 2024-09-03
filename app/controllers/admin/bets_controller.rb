class Admin::BetsController < ApplicationController
  def index
    # @bets = Bet.where('end_bet < ?', Time.current)
    @bets = Bet.all
  end

  def new
    @matches = Match.all
    @bet = Bet.new
  end

  def create; end

  def matches_autocomplete
    @matches = Match.where('name ILIKE ?', "#{params[:query]}%")
    render json: @matches.pluck(:name)
  end
end
