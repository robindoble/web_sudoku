require 'sinatra'
require 'sinatra/partial' 
require 'rack-flash'

require_relative './lib/sudoku'
require_relative './lib/cell'
require_relative './helpers/application'	
require_relative './lib/web_methods'

set :partial_template_engine, :erb
use Rack::Flash

enable :sessions
set :session_secret, "I'm the secret key to sign the cookie"

post '/new game' do
	# puts[params[:level]]
	difficulty = {"Easy" => 4, "Medium" => 5, "Hard" => 6}
  session[:cells_to_delete] = difficulty[params[:level]]
  session[:current_solution] = false
  session[:check_solution] = nil
  redirect to("/")
end

post '/' do
	cells = box_to_row(params['cell'])
	session[:current_solution] = cells.map {|value| value.to_i}.join
	session[:check_solution] = true
	redirect to('/')
end

get '/' do 
	session[:cells_to_delete] ||= 4
	prepare_to_check_solution
	generate_new_puzzle_if_necessary
	@current_solution = session[:current_solution] || session[:puzzle]
	@solution = session[:solution]
	@puzzle = session[:puzzle]
	erb :index
end

get '/solution' do
	@current_solution = session[:solution]
	erb :index
end





