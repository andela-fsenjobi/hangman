require 'hangman/version'
require 'hangman/word'
require 'hangman/message'
# require 'game'

module Hangman
  class Game
    include(Message)
    attr_accessor :turns, :history, :word, :feedback, :status

    def initialize(difficulty, feedback)
      word = Word.new
      @word = word.generate(difficulty)
      @history = []
      @turns = 7 + difficulty
      @feedback = feedback
      @status = 'play'
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
      if won? then game_won
      elsif lost? then game_lost
      else
        turns_prompt(@turns)
        show_word
      end
    end

    def show_word
      word = @word.split('')
      output = ''
      word.each do |letter|
        if @history.include?(letter)
          output << "#{letter} "
        else
          output << '_ '
        end
      end
      puts output
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
      if @feedback == 2
        won_gui(@word)
      else
        won_prompt(@word)
      end
      replay_prompt
      @history = []
      return false
      @status = 'restart'
    end

    def game_lost
      if @feedback == 2
        lost_gui(@word)
      else
        lost_prompt(@word)
      end
      replay_prompt
      @history = []
      @status = 'restart'
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

  class Router
    include(Message)
    attr_accessor :status, :difficulty, :feedback, :game
    def initialize
      @status = 'begin'
    end

    def process(input)
      if @status == 'begin'
        case input
          when 'p', 'play' then start_game
          when 'q', 'quit' then quit_game
          when 'l', 'load' then load_game
          when 'i', 'instructions' then instructions_prompt
          else invalid_prompt
        end
      elsif @status == 'feedback'
        @feedback = input.to_i
        if @feedback < 1 || @feedback > 2
          feedback_prompt
          return
        end
        level_prompt
        @status = 'start'
      elsif @status == 'start'
        @difficulty = input.to_i
        if @difficulty < 1 || @difficulty > 3
          level_prompt
          return
        end
        @status = 'play'
        begin_prompt
        @game = Game.new(@difficulty, @feedback)
        size_prompt(@game.word.size)
        turns_prompt(@game.turns)
        print_text(@game.show_word)
      elsif @status == 'play'
        if @game.status == 'restart'
          @status = 'start'
          process(input)
        else
          @game.control(input)
        end
      elsif @status == 'finish'
        if input == 'r' || 'restart'
          @status = 'start'
          process('p')
        elsif input == 'q' || 'quit'
          quit_game
        end
      elsif @status == 'quit'
        save_game
      end
    end

    def start_game
      @status = 'feedback'
      welcome_prompt
      feedback_prompt
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
      @status = 'end'
    end

    def load_game
      @status = 'load'
      load_prompt
      file = File.open('files/saved_games.txt', 'r')
      # i = 0
      # get_games(i, file)
      1.times { file.gets }
      game = $_.gsub("\n", '')
      2.times { file.gets }
      letters = $_
      letters.split(' ').pop
      1.times { file.gets }
      words = $_
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
end

session = Hangman::Router.new
session.instructions_prompt

repl = lambda do |prompt|
  print prompt
  session.process(gets.chomp!)
end

repl['% Hangman-0.1.0: '] while session.status != 'end'