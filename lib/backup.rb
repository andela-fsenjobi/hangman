class Game
  include(Message)
  attr_accessor :turns, :history, :word

  def initialize(difficulty)
    word = Word.new
    @word = word.generate(difficulty)
    @history = []
    @turns = 7 + difficulty
  end

  def play(input)
    if input.size > 1
      case input
        when ':h', 'history' then print_text("You have used: #{game_history}")
        when ':q', 'quit' then quit
        else invalid_promt
      end
    elsif input.size == 1
      include_letter(input, @history)
      @turns -= 1 unless @word.include?(input)
      check_game
    else
      invalid_prompt
    end
  end

  def include_letter(letter, history)
    if history.include?(letter)
      duplicate_prompt(letter)
      false
    else
      @history << letter
    end
  end

  def check_game
    if won? then won
    elsif lost? then game_lost
    else
      turns_prompt(@turns)
      print_text(show_word)
    end
  end

  def show_word(word, history)
    word = word.split('')
    output = ''
    word.each do |letter|
      if history.include?(letter)
        output << "#{letter} "
      else
        output << '_ '
      end
    end
  end

  # def process(input)
  #   if @status == 'begin'
  #     case input
  #       when 'p', 'play' then start_game
  #       when 'q', 'quit' then quit_game
  #       when 'l', 'load' then load_game
  #       when 'i', 'instructions' then instructions_prompt
  #       else invalid_prompt
  #     end
  #   elsif @status == 'start'
  #     input = input.to_i
  #     if input < 1 || input > 3
  #       level_prompt
  #       return
  #     end
  #     @status = 'play'
  #     begin_prompt
  #     word = Word.new
  #     word.generate(input.to_i)
  #     @words << word.generate(input)
  #     @turns = 6 + input
  #     size_prompt(@words.last.size)
  #     turns_prompt(@turns)
  #     show_word
  #   elsif @status == 'play'
  #     play(input)
  #   elsif @status == 'finish'
  #     if input == 'r' || 'restart'
  #       @status = 'start'
  #       process('p')
  #     end
  #   elsif @status == 'quit'
  #     save_game
  #   end
  # end

  # def start_game
  #   @status = 'start'
  #   welcome_prompt
  #   level_prompt
  # end

  def won?
    word = @word.split('')
    length = 0
    word.each {|val| length += 1 if @history.include?(val)}
    if length == word.size
      true
    else
      false
    end
  end

  def lost?
    @turns == 0
  end

  def game_won
    won_prompt(@words.last)
    replay_prompt
    @history = []
    @status = 'finish'
  end

  def game_lost
    puts lost_gui(@words.last)
    replay_prompt
    @history = []
    @status = 'finish'
  end

  def game_history
    output = ''
    if @history.empty?
      ''
    else
      @history.each {|letter| output << "#{letter} "}
    end
  end

  def quit_game
    @status = 'quit'
    save_prompt

    # do you want to save then quit
    # if yes then save
    # if not quit all the same
  end

  def save_game
    file = File.open('files/saved_games.txt', 'a')
    time = Time.new
    file.puts("#{time.ctime}")
    file.puts(@turns)
    @history.each { |letter| file.print("#{letter} ") }
    file.puts("\n")
    @words.each { |word| file.print("#{word} ") }
    file.puts("\n")
    file.close
    thanks_prompt
    $stop = true
  end

  def load_game
    @status = 'load'
    load_prompt
    file = File.open('files/saved_games.txt', 'r')
    # i = 0
    # get_games(i, file)
    1.times { file.gets }
    game = $LAST_READ_LINE
    4.times { file.gets }
    letters = $LAST_READ_LINE
    letters.split(' ').pop
    1.times { file.gets }
    words = $LAST_READ_LINE
    words = words.split(' ').last.split('')
    print "1: #{game} | "
    words.each do |word|
      if letters.include?(word)
        print "#{word} "
      else
        print '_ '
      end
    end
    print "\n"
  end
end