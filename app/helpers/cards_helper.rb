# frozen_string_literal: true

module CardsHelper
  def bet_type(bet)
    bet.parlay_group ? 'Parlay' : 'Pick'
  end

  def result_class(bet)
    if bet.won?
      'c-bet-card__result--won'
    elsif bet.won.nil?
      'c-bet-card__result--not-decided'
    else
      'c-bet-card__result--loss'
    end
  end

  def result_text(bet)
    if bet.won?
      'W'
    elsif bet.won.nil?
      'No result yet'
    else
      'L'
    end
  end
end
