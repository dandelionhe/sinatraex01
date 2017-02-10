require 'sinatra'
require 'sinatra/reloader' if development?
require 'sass'
require './song'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

get '/set/:name' do
  session[:name] = params[:name]
end

get '/login' do
  erb :login
end

get '/' do
  erb :home
end

get '/about' do
  @page_title= 'All About This Website'
  erb :about
end

get '/contact' do

  erb :contact
end

get('/style.css'){scss :styles}

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    erb :login
  end
end

get '/logout' do
  session.clear
  redirect to('/login')
end

not_found do
  erb :not_found
end