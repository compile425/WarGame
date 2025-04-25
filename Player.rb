class Player
  attr_reader :name, :pile
  attr_accessor :hand

  def initialize(name)
    @name = name
    @hand = []
    @pile = []
  end

  def play_card
    hand_replenishment if @hand.empty?
    @hand.shift
  end

  def acquire_cards(cards)
    @pile.concat(cards)
  end

  def hand_replenishment
    @hand = @pile.shuffle
    @pile = []
  end

  def total_cards
    @hand.size + @pile.size
  end

  def can_play?
    total_cards > 0
  end
end
