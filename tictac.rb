#Command line tic-tac toe, 7/19/12 Weds
#Useless trivia: Bill Gates wrote tic-tac toe as his first program
module TicTacGame
  attr_accessor :player_turn #whose turn is it?
  def setup_game(p1_mark='X',p2_mark='O',player_turn_start=1)
    @player_mark=Array.new(2)
    @player_mark[0]=p1_mark
    @player_mark[1]=p2_mark
    setup_board
    self.player_turn = player_turn_start
  end
  def game_loop
    while (!(board_filled?||three_marks?))
      render_board
      c_arr = get_player_input
      mark_board(c_arr[0],c_arr[1],@player_mark[self.player_turn-1]) if c_arr.size==2
      self.player_turn = (self.player_turn)%2+1
    end
    render_board
    if (three_marks?)
      puts "Player #{self.player_turn%2+1} wins"
    else
      puts "Draw"
    end
  end
  
  def setup_board
    #setup an 3x3 size board
    @board ||= Array.new(3){Array.new(3,"*")} #create 2D array, initialize empty string
  end
  def mark_board(x,y,c='X')
    #mark the board with an X or O at coords (x,y)
    #assume x<2 and y<2 and c=X or O
    @board[x-1][y-1]=c.upcase
  end
  def render_board
    #output the current board and its state
    for row in 0..2
      puts "#{@board[row][0]}|#{@board[row][1]}|#{@board[row][2]}"
    end
  end
  def board_filled?
    board_state = (@board.flatten).select { |x| x!="*" } #return 1d array, should be size 9 if filled
    return board_state.size == 9
  end
  def three_marks?
    @flag = Array.new(8,0) #[horiz,horiz,horiz,vert,vert,vert,diag,diag]
    x_score = 264
    o_score = 237
    #if someone gets 3 X's or O's, game over
    #to check sum the ascii values over the 2 diagonals, 3 verticals, 3 horizontals
    ##sum horizontals
    flat_board = @board.flatten
    flat_board.each_index do |i|
      @flag[0] = @flag[0]+flat_board[i].ord if i<3
      @flag[1] = @flag[1]+flat_board[i].ord if (i>=3&&i<6)
      @flag[2] = @flag[2]+flat_board[i].ord if (i>=6&&i<9)
    end
    ##sum verticals
    @flag[3]=flat_board[0].ord+flat_board[3].ord+flat_board[6].ord
    @flag[4]=flat_board[1].ord+flat_board[4].ord+flat_board[7].ord
    @flag[5]=flat_board[2].ord+flat_board[5].ord+flat_board[8].ord
    ##sum diagonals
    @flag[6]=flat_board[0].ord+flat_board[4].ord+flat_board[8].ord
    @flag[7]=flat_board[2].ord+flat_board[4].ord+flat_board[6].ord
    ##now check and see if we have 3 X's or 3 O's
    check_flag = @flag.select { |x| x==x_score||x==o_score}
    return !check_flag.empty?
  end
  def get_player_input
    valid_flag = false
    valid_input = InputValidator.new
    while (!valid_flag)
      puts "Player #{self.player_turn}, enter coordinates as row,col (1<=row<=3, 1<=col<=3):"
      coords = gets.chomp
      coords_arr=coords.split(",")
      valid_input.x_will_change!
      valid_input.y_will_change!
      valid_input.set_xy_coords(coords_arr[0],coords_arr[1])
      if (valid_input.valid?)
        valid_flag = true
         #a little contrived here - probably just need to check if array is < 2 elements instead of validating
        #returns an array of less than 2 elements if given faulty input
        coords_arr = coords_arr.map { |x| x.to_i }.reject { |x| !(x.is_a?(Integer))&&x<1&&x>3} 
      else
         puts "ERROR: Player #{self.player_turn}, #{valid_input.errors().full_messages}"
      end
    end
    puts "input changes #{valid_input.changes}"
    coords_arr #finally, a valid coords array
  end #get_player_input
end

#a Ruby class using ActiveModel::Validations to validate player input string
#assumes you're already working with a gemset containing rails
require 'active_model'
class InputValidator
  include ActiveModel::Validations
  include ActiveModel::Dirty
  validates_presence_of :x, :y
  validates_numericality_of :x, :y, :only_integer=>true, :less_than_or_equal_to => 3, :greater_than_or_equal_to => 1
  define_attribute_methods [:x, :y] #track changes to x,y for fun
  attr_accessor :x, :y
  
  def initialize(x=1,y=1)
    @x,@y=x,y #store the x,y coordinates
  end
  def set_xy_coords(x=1,y=1)
    @x=x
    @y=y
  end
  def get_xy_coords
    return [x,y]
  end
end

class MyGame
  include TicTacGame
end
mygame = MyGame.new
mygame.setup_game('X','O',1)
mygame.game_loop
