require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require './song'
require 'sinatra/flash'
require 'pony'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set :email_address => 'smtp.gmail.com',
      :email_user_name => 'yongzhenghe',
      :email_password => '3660308he',
      :email_domain => 'localhost.localdomain'
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :email_address => 'smtp.sendgrid.net',
      :email_user_name => ENV['SENDGRID_USERNAME'],
      :email_password => ENV['SENDGRID_PASSWORD'],
      :email_domain => 'heroku.com'
end

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

before do
  set_title
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

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message. We'll be in touch soon."
  redirect to('/')
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end

  def current?(path='/')
    (request.path == path || request.path==path+'/') ? "current" : nil
  end

  def set_title
    @title ||= 'Song By Sinatra'
  end

  def send_message
    Pony.mail(
            :from => params[:name] + "<" + params[:email] + ">",
            :to => 'yongzhenghesfo@gmail.com',
            :subject => params[:name] + "has contacted you",
            :body => params[:message],
            :port => '587',
            :via => :smtp,
            :via_options =>{
                :address => 'smtp.gmail.com',
                :port => '587',
                :enable_starttls_auto => true,
                :user_name => 'yongzhenghesfo',
                :password => '3660308he',
                :authentication => :plain,
                :domain => 'localhost.localdomain'
            }
    )
  end

end
