require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'
require 'line/bot'
require './src/lib/getTimeTable'
require './src/lib/getEndTime'
require './src/lib/getExam'
require './src/class/MessageButton'
require './src/class/MessageCarousel'
require './src/class/MessageConfirm'
require './lib'
require './scrayping'
require 'dotenv'
Dotenv.load

require './src/line'
require './src/bus'