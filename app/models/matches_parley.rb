# frozen_string_literal: true

class MatchesParley < ApplicationRecord
  belongs_to :parley
  belongs_to :match
end
