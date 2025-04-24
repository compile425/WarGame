class WarGame
    attr_reader :deck, :players
    def initialize
        num_players = ask_player_count
        @players = create_players(num_players)
        @deck = Deck.new(true)
        deal_cards
        puts "カードが配られました。"
    end

    def start
        puts "戦争を開始します。"
        war(@players)
        sorted_players = players.sort_by { |p| -p.total_cards }
        rank = 0
        last_score = -1

        sorted_players.each_with_index do |player, index|
            current_score = player.total_cards
            if current_score != last_score
                rank = index + 1
            end
            puts "#{rank}位: #{player.name} 手札の枚数#{current_score}枚"
            last_score = current_score
        end
        puts "戦争を終了します。"
    end

    private

    def ask_player_count
        num = 0
        loop do
            print "プレイヤーの人数を入力してください（2〜5）: "
            input = gets.chomp
            if input.match?(/^\d+$/) && (2..5).include?(input.to_i)
                num = input.to_i
                break
            else
                puts "2から5の整数を入力してください。"
            end
        end
        num
    end

    def create_players(num_players)
        players_ary = []
        num_players.times do |i|
            print "プレイヤー#{i + 1}の名前を入力してください: "
            name = gets.chomp.strip
            name = "プレイヤー#{i + 1}" if name.empty?
            players_ary << Player.new(name)
        end
        players_ary
    end

    def deal_cards
        all_hands = @deck.deal(@players.size)
        @players.each_with_index do |player, index|
            player.hand = all_hands[index] || []
        end
    end

    def war(players)
        pot = []
        war_state = false
        war_players = [] 

        loop do
            
            current_players = []
            if war_state
                current_players = war_players.select(&:can_play?)
                if current_players.size <= 1
                    winner = current_players.first
                    if winner && !pot.empty?
                        puts "#{winner.name}が勝ちました。#{winner.name}はカードを#{pot.size}枚もらいました。"
                        winner.acquire_cards(pot.shuffle)
                        pot = []
                    end
                    war_state = false 
                    war_players = []
                    next 
                end
            else
                current_players = players.select(&:can_play?)
                if current_players.size <= 1
                    break 
                end
                puts "戦争！"
            end
            played_this_turn = {}
            current_players.each do |player|
                card = player.play_card
                played_this_turn[player] = card
                if card
                    puts "#{player.name}のカードは#{card}です。"
                else
                    if war_state
                    else
                    end
                end
            end

            pot.concat(played_this_turn.values.compact)
            winners = []
            valid_plays = played_this_turn.select { |_, card| card }

            if valid_plays.empty?
                if war_state
                    war_state = false
                    war_players = []
                end
            else
                joker_players = valid_plays.select { |_, card| card.joker? }.keys
                if joker_players.size == 1
                    winners = joker_players
                    puts "#{winners.first.name}が勝ちました。"
                else
                    non_joker_plays = valid_plays
                    if non_joker_plays.any?
                        max_power = non_joker_plays.values.map(&:power).max
                        winners = non_joker_plays.select { |_, card| card.power == max_power }.keys
                        if winners.size == 1
                            puts "#{winners.first.name}が勝ちました。"
                        else
                            puts "引き分けです。"
                        end
                    end
                end
            end 
            if winners.size == 1
                winner = winners.first
                if !pot.empty?
                    puts "#{winner.name}はカードを#{pot.size}枚もらいました。"
                    winner.acquire_cards(pot.shuffle)
                    pot = []
                end
                if war_state
                    war_state = false
                    war_players = []
                end
            elsif winners.size > 1
                winner_names = winners.map(&:name).join(', ')
                first_winner_card = valid_plays[winners.first]

                spade_ace_player = nil
                ace_tie = first_winner_card&.rank == "A"
                if  ace_tie
                    spade_ace_player = winners.find { |player| valid_plays[player]&.spade_ace? } 
                end

                if spade_ace_player
                    puts "スペードのAは世界一！#{spade_ace_player.name}が勝ちました。"
                    if !pot.empty?
                        puts "#{spade_ace_player.name}はカードを#{pot.size}枚もらいました。"
                        spade_ace_player.acquire_cards(pot.shuffle)
                        pot = []
                    end
                    if war_state
                        war_state = false
                        war_players = []
                    end
                else
                    puts "戦争！"
                    war_state = true
                    war_players = winners
                end
            else
                
            end

            players.each do |p|
                if !p.can_play? && current_players.include?(p)
                    if war_state && war_players.include?(p)
                        war_players.delete(p)
                    end
                end
            end

            zero_card_players = players.select { |p| p.total_cards == 0 }
            if zero_card_players.any? 
               zero_card_players.each do |p|
               puts "#{p.name} の手札がなくなりました。"
               end
               puts "手札がないプレイヤーが出た為、最終順位を表示します。"
               break
            end

        end 
        end
    end 

class Card
  include Comparable
  attr_reader :rank, :suit, :power
  POWER_VALUES = { "2" => 2, "3" => 3, "4" => 4, "5" => 5, "6" => 6, "7" => 7, "8" => 8, "9" => 9, "10" => 10, "J" => 11, "Q" => 12, "K" => 13, "A" => 14, "ジョーカー" => 15}
  SUITS = %w[ハート ダイヤ クラブ スペード]
  RANKS = %w[2 3 4 5 6 7 8 9 10 J Q K A]
  
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

class Deck
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

war = WarGame.new
war.start