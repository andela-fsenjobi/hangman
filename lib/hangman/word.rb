module Hangman
  class Word
    def generate(difficulty)
      file = File.open('files/dictionary.txt', 'r')
      rand(41211).times { file.gets }
      word = clean_word($_)
      file.close
      if confirm(difficulty, word)
        word
      else
        generate(difficulty)
      end
    end

    def confirm(difficulty, word)
      if word.length >= 4 * difficulty && word.length <= 4 * (difficulty + 1)
        true
      else
        false
      end
    end

    def clean_word(word)
      cleaned_word = word.gsub("\n", '')
    end
  end
end
