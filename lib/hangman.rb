require 'hangman/version'
require 'hangman/word'
require 'hangman/message'

module Hangman
  class Game
    include(Message)
    attr_accessor :turns, :history, :status, :words, :feedback
    def initialize
      @words = []
      @history = []
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
        input = input.to_i
        if input < 1 || input > 3
          level_prompt
          return
        end
        @status = 'play'
        begin_prompt
        word = Word.new
        word.generate(input.to_i)
        @words << word.generate(input)
        @turns = 6 + input
        size_prompt(@words.last.size)
        turns_prompt(@turns)
        show_word
      elsif @status == 'play'
        play(input)
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

    def show_word
      word = @words.last.split('')
      word.each do |val|
        if @history.include?(val)
          print "#{val} "
        else
          print '_ '
        end
      end
      print "\n"
    end

    def start_game
      @status = 'feedback'
      welcome_prompt
      feedback_prompt
    end

    def play(input)
      if input.size > 1
        case input
          when ':h', 'history' then show_history
          when ':q', 'quit' then quit_game
          else invalid_promt
        end
      elsif input.size == 1
        include_letter(input)
        check_word(input)
      else
        invalid_prompt
      end
    end

    def check_word(input)
      if won? then game_won
      elsif lost? then game_lost
      else
        turns_prompt(@turns)
        show_word
      end
    end

    def include_letter(input)
      if @history.include?(input)
        duplicate_prompt(input)
      else
        @history << input
        @turns -= 1 unless @words.last.include?(input)
      end
    end

    def won?
      word = @words.last.split('')
      length = 0
      word.each do |val|
        length += 1 if @history.include?(val)
      end

      if length == word.size
        true
      else
        false
      end
    end

    def game_won
      if @feedback == 1
        won_prompt(@words.last)
      else
        won_gui(@words.last)
      end
      @history = []
      @status = 'finish'
      replay_prompt
    end

    def lost?
      @turns == 0
    end

    def show_history
      if @history.empty?
        empty_prompt
      else
        print 'You have used: '
        @history.each do |letter|
          print "#{letter} "
        end
        print "\n"
      end
    end

    def game_lost
      if @feedback == 1
        lost_prompt(@words.last)
      else
        lost_gui(@words.last)
      end
      @history = []
      @status = 'finish'
      replay_prompt
    end

    def quit_game
      @status = 'quit'
      save_prompt
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

game = Hangman::Game.new
game.instructions_prompt

repl = lambda do |prompt|
  print prompt
  game.process(gets.chomp!)
end

$stop = false

repl['% Hangman-0.1.0: '] while $stop == false