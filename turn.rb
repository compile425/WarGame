class Turn
    attr_reader :pot,
                :next_war_state,
                :next_war_participants,
                :turn_winner
                
    def initialize(players, current_pot, in_war_state)
      @players = players
      @pot = current_pot
      @in_war_state = in_war_state
      @played_cards_this_round = {}
      @turn_winner = nil
      @next_war_state = false
      @next_war_participants = []
    end
  
    def play
      display_turn_start_message
      collect_cards_from_players
      add_played_cards_to_pot
  
      winners = determine_round_winners(@played_cards_this_round)
      process_round_outcome(winners)
  
      {
        pot: @pot,
        next_war_state: @next_war_state,
        next_war_participants: @next_war_participants,
        turn_winner: @turn_winner
      }
    end
  
    private
  
    def display_turn_start_message
      puts "戦争！" unless @in_war_state
    end
  
    def collect_cards_from_players
      @players.each do |player|
        next unless player.can_play?
        card = player.play_card
        @played_cards_this_round[player] = card
        puts "#{player.name}のカードは#{card}です。" if card
      end
    end
  
    def add_played_cards_to_pot
      @pot.add_cards(@played_cards_this_round.values.compact)
    end
  
    def determine_round_winners(played_cards)
      valid_plays = played_cards.select { |_, card| card }
      return [] if valid_plays.empty?
  
      joker_winners = find_joker_winners(valid_plays)
      return joker_winners if joker_winners.any?
  
      find_normal_card_winners(valid_plays)
    end
  
    def find_joker_winners(valid_plays)
      joker_players = valid_plays.select { |_, card| card.joker? }.keys
      if joker_players.size == 1
        puts "#{joker_players.first.name}が勝ちました。"
      end
      joker_players
    end
  
    def find_normal_card_winners(valid_plays)
      max_power = valid_plays.values.map(&:power).max
      winners = valid_plays.select { |_, card| card.power == max_power }.keys
  
      if winners.size == 1 && max_power
        puts "#{winners.first.name}が勝ちました。"
      end
      winners
    end
  
    def process_round_outcome(winners)
      if winners.size == 1
        @turn_winner = winners.first
        @next_war_state = false
        @next_war_participants = []
      elsif winners.size > 1
        handle_tie_for_war(winners)
      else
        puts "この勝負は勝者なしでした。"
        @next_war_state = false if @in_war_state
        @next_war_participants = []
      end
    end
  
    def handle_tie_for_war(tie_winners)
      puts "引き分けです。"
      spade_ace_winner = check_for_spade_ace_winner_in_tie(tie_winners, @played_cards_this_round)
  
      if spade_ace_winner
        puts "スペードのAは世界一！#{spade_ace_winner.name}が勝ちました！"
        @turn_winner = spade_ace_winner
        @next_war_state = false
        @next_war_participants = []
      else
        puts "戦争！"
        @next_war_state = true
        @next_war_participants = tie_winners
      end
    end
  
    def check_for_spade_ace_winner_in_tie(tie_winners, played_cards)
      all_aces_in_tie = tie_winners.all? { |player| played_cards[player]&.rank == "A" }
      return nil unless all_aces_in_tie
      tie_winners.find { |player| played_cards[player]&.spade_ace? }
    end
  end