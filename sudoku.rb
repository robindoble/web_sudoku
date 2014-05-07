require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application'	
require 'sinatra/partial' 
require 'rack-flash'


set :partial_template_engine, :erb
use Rack::Flash

enable :sessions
set :session_secret, "I'm the secret key to sign the cookie"

def random_sudoku
		seed =(1..9).to_a.shuffle + Array.new(81-9,0)
		sudoku=Sudoku.new(seed.join)
		sudoku.solve!
		sudoku.to_s.chars
end

def rand_select(cells_to_blank, array, max=7)
  base_case = (cells_to_blank == 0) || (array.select{|x| x == '0'}.count >= max)
  return array if cells_to_blank == 0
  random = rand(0..8)
  if array[random] == '0'
    return rand_select(cells_to_blank, array, max)
  else
    array[random] = '0'
    rand_select(cells_to_blank-1, array, max)
  end
end

def puzzle(sudoku,difficulty=4)
  boxes = box_to_row(sudoku).each_slice(9).map{|box| rand_select(difficulty, box)}.flatten
  rows = box_to_row(boxes)
end

def box_to_row(cells)
  rows = cells.each_slice(27).to_a
  rows.map do |row| 
    a = row.each_slice(9).to_a.map{|box| box.each_slice(3)}
    a[0].zip(a[1]).zip(a[2])
end.flatten
end

post '/' do
	cells = box_to_row(params['cell'])
	session[:current_solution] = cells.map {|value| value.to_i}.join
	# puts session[:current_solution].inspect
	session[:check_solution] = true
	redirect to('/')
end

get '/' do 
	prepare_to_check_solution
	generate_new_puzzle_if_necessary
	@current_solution = session[:current_solution] || session[:puzzle]
	@solution = session[:solution]
	@puzzle = session[:puzzle]
	erb :index
end

def generate_new_puzzle_if_necessary
	return if session[:current_solution]
	sudoku = random_sudoku
	session[:solution] = sudoku
	session[:puzzle] = puzzle(sudoku)
	session[:current_solution] = session[:puzzle]
end

def prepare_to_check_solution
	@check_solution = session[:check_solution]
		if @check_solution
				flash[:notice] = 'Incorrect values are highlighted in yellow'
		end
	session[:check_solution] = nil
end

def read_only(cell_value)
	cell_value.to_i != 0 ? "read_only" : "" 
end

get '/solution' do
	@current_solution = session[:solution]
	erb :index
end





