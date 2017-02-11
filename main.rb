require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
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

get '/login' do
  slim :login
end

post '/login' do
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to ('/songs')
  else
    slim :login
  end
end

get '/logout' do
  session.clear
  redirect to('/login')
end

get '/' do
  slim :home
end

get '/about' do
  @page_title= 'All About This Website'
  slim :about
end

get '/contact' do

  slim :contact
end

get ('/styles.css'){scss :styles}



not_found do
  slim :not_found
end