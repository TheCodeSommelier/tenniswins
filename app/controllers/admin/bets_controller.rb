# frozen_string_literal: true

module Admin
  class BetsController < ApplicationController
    before_action :set_bet, only: %i[edit update destroy]

    def index
      @grouped_bets = policy_scope(Bet).includes(:match)
                                       .order(created_at: :desc)
                                       .group_by { |bet| bet.parlay_group || bet.id }
                                       .values

      @paginated_groups = Kaminari.paginate_array(@grouped_bets)
                                  .page(params[:page])
                                  .per(6)
    end

    def new
      @matches = Match.all
      @bet = Bet.new
      authorize @bet
    end

    def create
      permitted_params = bets_params
      parlay_group_id = SecureRandom.uuid if permitted_params.keys.length > 1

      @bets = permitted_params.to_h.values.map do |bets_params|
        bet = Bet.new(bets_params.except(:name))
        bet.parlay_group = parlay_group_id if parlay_group_id
        bet.match = Match.find_by(name: bets_params[:name]) || Match.create(name: bets_params[:name])
        authorize bet
        bet
      end

      if @bets.all?(&:valid?)
        @bets.each(&:save)
        redirect_to admin_bets_path, notice: 'Your pick/parlay is created!'
      else
        flash.now[:alert] = "Something went wrong! #{@bets.flat_map { |bet| bet.errors.full_messages }}"
        render :new, status: 422
      end
    end

    def edit
      authorize @bet
      @bets = Bet.where(parlay_group: @bet.parlay_group) if @bet.part_of_parlay?
    end

    def update
      authorize @bet

      @bets = @bet.part_of_parlay? ? Bet.where(parlay_group: @bet.parlay_group) : [@bet]

      permitted_params = bets_params.to_h

      update_successful = true

      @bets.each do |bet|
        bet_data = permitted_params.values.find { |data| data[:betId].to_i == bet.id }

        if bet_data
          unless bet.update(bet_data.except(:name, :betId)) && bet.match.update(name: bet_data[:name])
            update_successful = false
            break
          end
        else
          update_successful = false
          break
        end
      end

      # Respond based on update success or failure
      if update_successful
        redirect_to admin_bets_path, notice: 'Bets were successfully updated.'
      else
        flash.now[:alert] = "Update failed. Errors: #{@bets.flat_map do |bet|
                                                        bet.errors.full_messages
                                                      end.uniq.join(', ')}"
        render :edit, status: :unprocessable_entity
      end
    end

    def matches_autocomplete
      @matches = Match.where('name ILIKE ?', "#{params[:query]}%")
      render json: @matches.pluck(:name)
    end

    def destroy
      @bet = Bet.find(params[:id])
      authorize @bet

      if @bet.part_of_parlay?
        parlay_group_bets = Bet.where(parlay_group: @bet.parlay_group)
        parlay_group_bets.destroy_all
      else
        @bet.destroy
      end

      respond_to do |format|
        format.html do
          redirect_to admin_bets_path, notice: 'We have successfully deleted the record from the database...'
        end
        format.turbo_stream
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to admin_bets_path, alert: 'We could not find the record you are trying to delete...'
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

    def edit_bet_data
      @bet = Bet.find(params[:id])
      @bets = @bet.part_of_parlay? ? Bet.where(parlay_group: @bet.parlay_group) : [@bet]
      @matches = @bet.part_of_parlay? ? @bets.map { |bet| bet.match.name } : [@bet.match.name]

      render json: { bets: @bets, matches: @matches }
    end

    private

    def set_bet
      @bet = Bet.find(params[:id].to_i)
    end

    def bets_params
      params.require(:bets).permit!.tap do |whitelisted|
        whitelisted.each do |key, value|
          whitelisted[key] = value.permit(:name, :odds, :us_odds, :betId) if value.is_a?(ActionController::Parameters)
        end
      end
    end
  end
end
