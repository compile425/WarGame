class Deck
  require_relative "Card"
  attr_reader :cards

  def initialize(include_joker = false)
    @cards = Card::SUITS.flat_map { |s| Card::RANKS.map { |r| Card.new(r, s) } }.shuffle
    if include_joker
      @cards << Card.new("ジョーカー", nil)
    end
    shuffle!
  end

  def deal(num_players)
    cards_per_player = @cards.size / num_players
    total_cards_to_deal = cards_per_player * num_players
    dealing_cards = @cards.take(total_cards_to_deal)
    dealing_cards.each_slice(cards_per_player).to_a
  end

  def shuffle!
    @cards.shuffle!
  end
end
