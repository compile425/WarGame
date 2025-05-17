class Pot
    attr_reader :cards
  
    def initialize
      @cards = []
    end
  
    def add_cards(new_cards)
      @cards.concat(new_cards.compact)
    end
  
    def give_winnings_to(player)
      return if @cards.empty?
      puts "#{player.name}はカードを#{@cards.size}枚もらいました。"
      player.acquire_cards(@cards.shuffle)
      clear
    end
  
    def clear
      @cards = []
    end
  
    def empty?
      @cards.empty?
    end
  
    def size
      @cards.size
    end
  end