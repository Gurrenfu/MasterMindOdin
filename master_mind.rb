require 'pry-byebug'
module GamePieces
  COLORS = %w[R B G Y W P]
  PERFECT_PIN = '!'
  COLOR_ONLY_PIN = '~'
end

class HumanController
  include GamePieces

  def get_row
    answer = get_input("Please Choose 4: #{COLORS.join(' ')}", COLORS)
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

  def get_pins(_guess)
    get_input("Please choose the pins: #{PERFECT_PIN} = correct, #{COLOR_ONLY_PIN} = color only",
              [PERFECT_PIN, COLOR_ONLY_PIN]).shift(4)
  end

  def check_guess(_guess, _solution)
    get_input('Is the guess correct? Y/N', %w[Y N]) == 'Y'
  end

  def get_input(message, valid_answers)
    answer = nil
    valid_input = false
    until valid_input
      puts message
      answer = gets.chomp.delete(' ').upcase.split('')
      valid_input = validate_input(answer, valid_answers)
    end
    answer
  end

  def validate_input(input, valid_answers)
    if input.all? { |c| valid_answers.include?(c) }
      true
    else
      puts 'Please check your input'
      false
    end
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
    solution_check_array = solution.clone
    guess.each_with_index do |color, index|
      if solution_check_array.include?(color)
        solution_check_array.index(color) == index ? pins.push(PERFECT_PIN) : pins.push(COLOR_ONLY_PIN)
        solution_check_array[solution_check_array.index(color)] = nil # handle duplicate colors
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
    @board_pins = Array.new { Array.new }
  end

  def display_board
    @board_data.each_slice(2) { |row| puts "#{row[0].join('|')}    #{row[1].join(' ')}" }
  end

  def add_new_row(new_row)
    @board_data.push(new_row)
  end

  def add_new_pins(new_row)
    @board_pins.push(new_row)
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
    p @chooser.set_solution
    puts "Solution Set"
    until game_over
      new_guess = @guesser.do_guess
      @board.add_new_row(new_guess)
      if @chooser.check_guess(new_guess)
        game_over = true
        break
      else
        @board.add_new_row(@chooser.do_pins(new_guess))
        @current_round += 1
        game_over = true if @current_round >= @total_rounds
      end
      puts "\n"
      @board.display_board
    end
  end
end

person = HumanController.new
computer = ComputerController.new

game_manager = GameManager.new(person, computer)
game_manager.play
# game_manager.board.add_new_row(%w[R B G Y W P])


