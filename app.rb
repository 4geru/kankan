require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'
require 'nokogiri'
require 'open-uri'
require 'line/bot'
require './timetable'

get '/' do
  'hello'
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
        if event.message['text'] =~ /授業/ and event.message['text'] =~ /今日/
          p 'ok'
          t = Time.new()
          msg = op(t.month, t.day)
        end
        unless msg
          message = {
            type: 'text',
            text: msg
          }
          client.reply_message(event['replyToken'], message)
        end
      end
    end
  }

  "OK"
end