Bundler.require(:default, ENV['RACK_ENV'])
require './main'
run Sinatra::Application