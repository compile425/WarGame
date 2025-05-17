require_relative "Player"
require_relative "Deck"
require_relative "Turn"
require_relative "Pot"

class WarGame
  attr_reader :deck, :players

  def initialize
    @players = initialize_players
    @deck = Deck.new(true)
    deal_cards
    puts "カードが配られました。"
  end

  def start
    puts "戦争を開始します。"
    play_game_loop
    announce_ranking
    puts "戦争を終了します。"
  end

  private

  def initialize_players
    num_players = ask_player_count
    create_players(num_players)
  end

  def ask_player_count
    loop do
      print "プレイヤーの人数を入力してください（2〜5）: "
      input = gets.chomp
      return input.to_i if input.match?(/^\d+$/) && (2..5).cover?(input.to_i)
      puts "2から5の整数を入力してください。"
    end
  end

  def create_players(num_players)
    Array.new(num_players) do |i|
      print "プレイヤー#{i + 1}の名前を入力してください: "
      name = gets.chomp.strip
      name = "プレイヤー#{i + 1}" if name.empty?
      Player.new(name)
    end
  end

  def deal_cards
    all_hands = deck.deal(players.size)
    players.each_with_index do |player, index|
      player.hand = all_hands[index] || []
    end
  end

  def play_game_loop
    pot = Pot.new
    war_context = { state: false, participants: [] }

    loop do
      active_players = determine_active_players(war_context)

      if game_over?(active_players, pot, war_context[:state])
        break
      end

      current_turn = Turn.new(active_players, pot, war_context[:state])
      turn_result = current_turn.play

      update_game_state_after_turn(pot, war_context, turn_result)

      break if round_winner_ends_game?(turn_result[:turn_winner], pot)
      break if war_cannot_continue?(war_context, pot)
    end
  end

  def determine_active_players(war_context)
    if war_context[:state]
      war_context[:participants].select(&:can_play?)
    else
      players.select(&:can_play?)
    end
  end

  def game_over?(active_players, current_pot, current_war_state) # war_state を受け取る
    if active_players.empty?
      handle_no_active_players_remaining(current_pot)
      return true
    elsif active_players.size == 1 && !current_war_state
      handle_single_remaining_player(active_players.first, current_pot)
      return true
    end
    false
  end

  def update_game_state_after_turn(current_pot, war_context_hash, turn_result_hash)
    war_context_hash[:state] = turn_result_hash[:next_war_state]
    war_context_hash[:participants] = turn_result_hash[:next_war_participants]
  end

  def round_winner_ends_game?(round_winner, current_pot)
    return false unless round_winner

    current_pot.give_winnings_to(round_winner)
    if any_player_has_zero_cards?
      puts "手札が0枚になったプレイヤーが出たため、このラウンドの勝者 #{round_winner.name} が全てのカードを獲得しゲーム終了です。"
      return true
    end
    false
  end

  def war_cannot_continue?(war_context, current_pot)
    if war_context[:state] && determine_active_players(war_context).size <= 1
      if !current_pot.empty?
        puts "Warを継続できず、場のカード#{current_pot.size}枚は流されました。"
        current_pot.clear
      end
      return true
    end
    false
  end

  def any_player_has_zero_cards?
    players.any? { |player| !player.can_play? }
  end

  def handle_no_active_players_remaining(pot_object)
    puts "プレイ可能なプレイヤーがいなくなり、ゲームを終了します。"
    puts "場のカード#{pot_object.size}枚は流されました。" unless pot_object.empty?
    pot_object.clear
  end

  def handle_single_remaining_player(winner, pot_object)
    puts "#{winner.name}のみがプレイ可能なため、ゲームを終了します。"
    pot_object.give_winnings_to(winner) unless pot_object.empty?
  end

  def announce_ranking
    puts "\n--- 最終結果 ---"
    sorted_players = players.sort_by { |p| -p.total_cards }
    rank = 0
    last_total_cards = -1

    sorted_players.each_with_index do |player, index|
      current_total_cards = player.total_cards
      rank = index + 1 if current_total_cards != last_total_cards
      puts "#{rank}位: #{player.name} (獲得カード枚数 #{current_total_cards}枚)"
      last_total_cards = current_total_cards
    end
  end
end

game = WarGame.new
game.start