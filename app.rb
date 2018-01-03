require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'
require 'line/bot'
require './timetable'
require './exam'
require './messagebutton'
require './messagecarousel'
require './lib'
require './scrayping'

require './src/web'
require './src/line'