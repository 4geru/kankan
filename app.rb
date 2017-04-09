require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'
require 'nokogiri'
require 'open-uri'
require 'line/bot'
require 'logger'
require './timetable'

logger = Logger.new(STDOUT)

get '/' do
  t = Time.new()
  msg = op(t.month, t.day)
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
        if event.message['text'] =~ /授業/ and event.message['text'] =~ /今日/
          msg = op(t.month, t.day)
        elsif event.message['text'] =~ /授業/ and event.message['text'] =~ /明日/
          msg = op(t.month, t.day + 1)
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