require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require './song'
require 'sinatra/flash'
require 'pony'
require './sinatra/auth'
require 'v8'
require 'coffee-script'

configure :development do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
  set :email_address => 'smtp.gmail.com',
      :email_user_name => 'yongzhenghe',
      :email_password => '888',
      :email_domain => 'localhost.localdomain'
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  set :email_address => 'smtp.sendgrid.net',
      :email_user_name => ENV['SENDGRID_USERNAME'],
      :email_password => ENV['SENDGRID_PASSWORD'],
      :email_domain => 'heroku.com'
end

before do
  set_title
end

get '/login' do
  slim :login
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
get ('/javascripts/application.js'){ coffee :application}

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
                :password => '***',
                :authentication => :plain,
                :domain => 'localhost.localdomain'
            }
    )
  end

end
