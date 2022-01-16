require 'pry-byebug'
module GamePieces
  COLORS = %w[R B G Y W P]
  PERFECT_PIN = '!'
  COLOR_ONLY_PIN = '~'
end

#check that inputs match a set of accepted values
module UserInput
  def self.get_input(message, valid_answers)
    answer = nil
    valid_input = false
    until valid_input
      puts message
      answer = gets.chomp.delete(' ').upcase.split('')
      valid_input = self.validate_input(answer, valid_answers)
    end
    answer
  end

  def self.validate_input(input, valid_answers)
    if input.all? { |c| valid_answers.include?(c) }
      true
    else
      puts 'Please check your input'
      false
    end
  end
end

class HumanController
  include GamePieces
  include UserInput

  def get_row
    answer = UserInput.get_input("Please Choose 4: #{COLORS.join(' ')}", COLORS)
    #ensure array of length 4 is returned
    if answer.length >= 4
      answer.shift(4)
    else
      for i in (answer.length)..3
        answer[i] = ' '
      end
      answer
    end
  end

  def get_pins(_guess,_solution)
    UserInput.get_input("Please choose the pins: #{PERFECT_PIN} = correct, #{COLOR_ONLY_PIN} = color only", [PERFECT_PIN, COLOR_ONLY_PIN]).shift(4)
  end

  def check_guess(_guess, _solution)
    UserInput.get_input('Is the guess correct? Y/N', %w[Y N]).join == 'Y'
  end
end

class ComputerController
  include GamePieces

  def get_row
    COLORS.shuffle.shift(4)
  end

  # create clone of solution to check guess
  # after each correct color it is removed to check for duplicate colors
  def get_pins(guess, solution)
    pins = []
    guess_check_array = guess.clone
    solution_check_array = solution.clone

    guess_check_array.each_with_index do |color, index|
      if solution_check_array.include?(color) && solution_check_array[index] == color
          pins.push(PERFECT_PIN)
          color = nil
          solution_check_array[index] = nil
      end
    end

    guess_check_array.each do |color|
      if solution_check_array.include?(color)
        pins.push(COLOR_ONLY_PIN)
        solution_check_array[solution_check_array.index(color)] = nil  # handle duplicate colors
      end
    end
    pins
  end
    
  def check_guess(guess, solution)
    guess == solution
  end
end

class Guesser
  attr_reader :guesses

  def initialize(controller)
    @controller = controller
    @guesses = []
  end

  def do_guess
    guess = @controller.get_row
    @guesses.push(guess)
    guess
  end
end

class Chooser
  attr_reader :solution

  def initialize(controller)
    @controller = controller
    @solution = Array.new(4)
  end

  def set_solution
    puts 'Setting Solution...'
    @solution = @controller.get_row
    @solution
  end

  def check_guess(guess)
    @controller.check_guess(guess, @solution)
  end

  def do_pins(guess)
    @controller.get_pins(guess, @solution)
  end
end

class Board
  def initialize
    @board_data = Array.new { Array.new }
  end

  #show colors and coresponding pins
  def display_board
    puts"========"
    @board_data.each_slice(2) { |row| puts "#{row[0].join('|')}    #{row[1].join(' ')}" }
    puts"========"
  end

  def add_new_row(new_row)
    @board_data.push(new_row)
  end
end

class GameManager
  attr_reader :board, :guesser, :chooser, :total_rounds, :current_round

  def initialize(guesser_controller, chooser_controller)
    @guesser = Guesser.new(guesser_controller)
    @chooser = Chooser.new(chooser_controller)
    @board = Board.new
    @total_rounds = 12
    @current_round = 1
  end

  def play
    game_over = false
    @current_round = 1
    @chooser.set_solution
    puts "\nRound: #{current_round}/#{@total_rounds}"

    until game_over
      new_guess = @guesser.do_guess
      @board.add_new_row(new_guess)
      puts "Current Guess: #{new_guess.join('|')}"
      if @chooser.check_guess(new_guess)
        game_over = true
        puts "\nGUESSER WINS!!"
        break
      else
        @board.add_new_row(@chooser.do_pins(new_guess))
        @current_round += 1
        if @current_round > @total_rounds
          game_over = true 
          puts "\nGAME OVER!!\nSolution: #{@chooser.solution.join('|')}"
          break
        end
      end

      puts "\nRound: #{current_round}/#{@total_rounds}"
      @board.display_board
    end
  end
end


close_game = false
person = HumanController.new
computer = ComputerController.new
until close_game
  puts "Let's play MasterMind"

  selection = UserInput.get_input('Are you the Guesser or Chooser: G C ?', %w[G C]).join
  if selection == 'G'
    game_manager = GameManager.new(person, computer)
  else
    game_manager = GameManager.new(computer, person)
  end

  game_manager.play

  quit = UserInput.get_input("\n Play Again: Y/N  ?", %w[Y N]).join
  close_game = (quit == 'N')
end

puts "\nTHANKS FOR PLAYING"


