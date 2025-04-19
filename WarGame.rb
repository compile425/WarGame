class WarGame
    attr_reader :deck

    def initialize
        @player1 = Player.new("プレイヤー1")
        @player2 = Player.new("プレイヤー2")
        @deck = Deck.new
        p1_hand, p2_hand = deck.deal 
        @player1.hand = p1_hand
        @player2.hand = p2_hand
    end

    def start
        puts "戦争！"
        war(@player1, @player2)
    end

    private

    def war(p1, p2, pot = [])
        c1 = p1.play
        c2 = p2.play
        puts "#{p1.name}のカードは#{c1}です。"
        puts "#{p2.name}のカードは#{c2}です。"
        pot.push(c1, c2)
        if c1.power > c2.power
            puts "#{p1.name}が勝ちました"
            p1.pot_get(pot)
            puts "戦争を終了します。"
        elsif c2.power > c1.power
            puts "#{p2.name}が勝ちました"
            p2.pot_get(pot)
            puts "戦争を終了します。"
        else
            puts "引き分けです。"
            war(@player1, @player2)
        end

    end



end

class Card
  attr_reader :rank, :suit
  POWER_VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "10" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14}
  
  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{@suit}の#{@rank}"
  end

  def power
    POWER_VALUES[@rank]
  end 


end

class Deck
    attr_reader :cards
    RANK_CARDS = %w[2 3 4 5 6 7 8 9 10 J Q K A]
    SUIT_CARDS = ["ハート", "ダイヤ", "クラブ", "スペード"]

    def initialize
        @cards = SUIT_CARDS.flat_map{ |s| RANK_CARDS.map{ |r| Card.new(r, s)} }.shuffle
    end

    def deal
        [@cards[0, 26], @cards[26, 26]]
    end
end

class Player
    attr_reader :name
    attr_accessor :hand

    def initialize(name)
        @name = name
        @hand = []
    end

    def play
        hand.shift
    end

    def pot_get(cards)
        hand.concat(cards)
    end

end

war = WarGame.new
war.start