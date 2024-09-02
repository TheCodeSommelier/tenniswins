class Match < ApplicationRecord
  belongs_to :pick

  has_many :matches_parleys
  has_many :matches, through: :matches_parleys
end
