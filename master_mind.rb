# chooser vs guesser
# colors: R B G Y W P 
# pins: ! ~ (!= correct color and position ) (~ = correct color only)
# 
# chooser randomly picks the solution

# guesser types a code 
# chooser compares guesser code vs solution
# 
# if code is correct, ask to start a new game
# if incorrect, assign pins and go to next round
# go for 12 rounds 
module GamePieces
  COLORS = %w(R B G Y W P)
  PERFECT_PIN = '!'
  COLOR_ONLY_PIN = '~'
end
#board class
# displays pins, guesses, round number 
class Board
    def initialize
      @board_data = Array.new(){Array.new()}
    end

    def display_board
     @board_data.each{|row| puts row.join('|')}
    end

    def add_new_row(new_row)
      @board_data.push(new_row)
    end
end
#gameManager class
# connects guesser, chooser, board
# holds game loop 
class GameManager 
    attr_reader :board, :guesser, :chooser, :total_rounds, :current_round

    def initialize (guesser_controller, chooser_controller)
     @guesser = Guesser.new(guesser_controller)
     @chooser = Chooser.new(chooser_controller)
     @board = Board.new()
     @total_rounds = 12
     @current_round = 1
    end

    def play
     game_over = false
     @chooser.set_solution
     until game_over
        new_guess = @guesser.get_guess
        if @chooser.check_guess(new_guess)
            game_over = true
            break
        else
          @chooser.get_pins(new_guess)
          @current_round += 1
          if @current_round >= @total_rounds  
            game_over = true 
          end
        end
     end
    end

    
end

#guesser class
# creates and holds each guess
class Guesser 
    attr_reader :guesses
    def initialize (controller)
      @controller = controller
      @guesses = Array.new
    end
  
    def get_guess
      @controller.get_row
      # add to guesses
      # return guess 
    end
end
  
#chooser class
# creates and holds solution
# compares to solution
class Chooser
    attr_reader :solution

    def initialize (controller)
        @controller = controller
        @solution = Array.new(4)
    end

    def set_solution
        @controller.get_row
    end

    def check_guess(guess)
        #check guess against solution
        #return bool
    end

    def get_pins
        @controller.get_pins
    end

end

class Controller
    def get_row
        # handle validation 
    end

    def get_pins
        # handle validation 
    end
end

class HumanController < Controller
  def get_row
    row_string = gets.chomp
  end

  def get_pins
    pins_string = gets.chomp
  end
end

class ComputerController < Controller
    def get_row
        # random generation 
    end

    def get_pins
        # comparation alogrithim
    end
end

#game class
# asks to replay
# sets the player and computer into their positions
player = HumanController.new()
computer = ComputerController.new()

game_manager = GameManager.new(player, computer)
game_manager.board.add_new_row(%w(R B G Y W P))
game_manager.board.display_board
