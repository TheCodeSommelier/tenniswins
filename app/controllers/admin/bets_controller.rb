class Admin::BetsController < ApplicationController
  def index
    # @bets = Bet.where('created_at > ?', Time.current - 2.days)
    @bets = Bet.all
  end

  def new
    @matches = Match.all
    @bet = Bet.new
  end

  def create
    permitted_params = bets_params
    p "🔥 permitted_params #{permitted_params}"
    parlay_group_id = SecureRandom.uuid if permitted_params.keys.length > 1

    @bets = permitted_params.to_h.values.map do |bets_params|
      bet = Bet.new(bets_params.except(:name))
      bet.parlay_group = parlay_group_id if parlay_group_id
      bet.match = Match.find_by(name: bets_params[:name])
      bet
    end

    if @bets.all?(&:valid?)
      @bets.each(&:save)
      redirect_to admin_bets_path, notice: 'Your pick/parlay is created!'
    else
      flash.now[:notice] = 'Something went wrong!'
      render :new
    end
  end

  def matches_autocomplete
    @matches = Match.where('name ILIKE ?', "#{params[:query]}%")
    render json: @matches.pluck(:name)
  end

  def bet_won
    return unless %w[true false].include?(params[:html_options][:won])

    is_uuid = params[:html_options][:bet_id].match?(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i)
    won_params = params[:html_options][:won] == 'true'

    bet_id = params[:html_options][:bet_id].to_i unless is_uuid
    parlay_id = params[:html_options][:bet_id] if is_uuid

    Bet.find(bet_id).update(won: won_params) if bet_id
    Bet.where(parlay_group: parlay_id).update_all(won: won_params) if parlay_id

    redirect_to admin_bets_path
  end

  private

  def bets_params
    params.require(:bets).permit!.tap do |whitelisted|
      whitelisted.each do |key, value|
        whitelisted[key] = value.permit(:name, :odds, :us_odds) if value.is_a?(ActionController::Parameters)
      end
    end
  end
end
