class Parley < ApplicationRecord
  belongs_to :matches_parleys

  has_many :matches, through: :matches_parleys
end
