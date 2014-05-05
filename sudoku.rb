require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'
	
enable :sessions

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


get '/' do 
	sudoku = random_sudoku
	session[:solution] = sudoku	
	@current_solution = puzzle(sudoku)
	erb :index
end

get '/solution' do
	@current_solution = session[:solution]
	erb :index
end
