require 'bundler'
Bundler.require

use Rack::Auth::Basic do |username, password|
  username == ENV['BASIC_AUTH_USERNAME'] && password == ENV['BASIC_AUTH_PASSWORD']
end

require './app'
run Sinatra::Application
