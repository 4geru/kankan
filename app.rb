require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'
require 'nokogiri'
require 'open-uri'
require 'line/bot'
require 'logger'
require './timetable'

helpers do
  def protect!
    unless authorized?
      response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
      throw(:halt, [401, "Not authorized\n"])
    end
  end
  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    username = ENV['BASIC_AUTH_USERNAME']
    password = ENV['BASIC_AUTH_PASSWORD']
    @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [username, password]
  end
end

logger = Logger.new(STDOUT)

get '/' do
  'ok'
end

get '/protect' do
  protect!
  'アクセス制限あり'
end

get '/api/:month/:day' do
  msg = op(params[:month], params[:day])
end

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        msg = nil
        t = Time.new()
        if (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /今日/
          msg = op(t.month, t.day)
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /明日/
          msg = op(t.month, t.day + 1)
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /\//
          m = str.match(/(\d{1,2})\/(\d{1,2})/)
          begin
            t = Time.parse(t.year.to_s + '/' + month.to_s + '/'  + day.to_s + ' 00:00:00')
            msg = op(t.month, t.day + 1)
          rescue => e
            msg = '日付の入力を治してください 月/日'
          end
        end
        
        if not msg.nil?
          message = {
            type: 'text',
            text: msg
          }
          client.reply_message(event['replyToken'], message)
          logger.info('replied message')
        end
      end
    end
  }

  "OK"
end