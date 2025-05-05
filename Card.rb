class Card
  include Comparable

  POWER_VALUES = {
    "2" => 2,
    "3" => 3,
    "4" => 4,
    "5" => 5,
    "6" => 6,
    "7" => 7,
    "8" => 8,
    "9" => 9,
    "10" => 10,
    "J" => 11,
    "Q" => 12,
    "K" => 13,
    "A" => 14,
    "ジョーカー" => 15
  }.freeze
  SUITS = %w[ハート ダイヤ クラブ スペード]
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A]

  attr_reader :rank, :suit, :power

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
    @power = POWER_VALUES[@rank]
  end

  def to_s
    if joker?
      "ジョーカー"
    else
      "#{@suit}の#{@rank}"
    end
  end

  def joker?
    @rank == "ジョーカー"
  end

  def spade_ace?
    @rank == "A" && @suit == "スペード"
  end

  def <=>(other_card)
    self.power <=> other_card.power
  end
end
