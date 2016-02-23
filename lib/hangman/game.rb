module Hangman
  class Game
    include(Message)
    attr_accessor :turns, :history, :word, :feedback

    def initialize(difficulty, feedback)
      word = Word.new
      @word = word.generate(difficulty)
      @history = []
      @turns = 7 + difficulty
      @feedback = feedback
    end

    def control(input)
      if input.size > 1
        commands(input)
      elsif input.size == 1
        play(input)
      else
        invalid_prompt
      end
    end

    def commands(input)
      case input
        when ':h', 'history' then print_text("You have used: #{game_history}")
        when ':q', 'quit' then quit
        else invalid_promt
      end
    end

    def play(input)
      include_letter(input, @history)
      @turns -= 1 unless @word.include?(input)
      check_game
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
    end
  end
end