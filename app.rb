require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models/count.rb'
require 'nokogiri'
require 'open-uri'
require 'line/bot'
require 'logger'
require './timetable'
require './messagebutton'

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
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        msg = nil
        t = Time.new()
        if (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /今日/
          msg = "#{t.month}/#{t.day}\n" + op(t.month, t.day)
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /明日/
          msg = "#{t.month}/#{t.day}\n" + op(t.month, t.day + 1)
        elsif (event.message['text'] =~ /試験/ or event.message['text'] =~ /テスト/)  and event.message['text'] =~ /(\d{1,2})\/(\d{1,2})/
          begin
            m = event.message['text'].match(/(\d{1,2})\/(\d{1,2})/)
            t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
            msg = exam(t.month, t.day)
          rescue => e
            msg = '日付の入力を直してください 月/日'
          end
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /(\d{1,2})\/(\d{1,2})/
          begin
            m = event.message['text'].match(/(\d{1,2})\/(\d{1,2})/)
            t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
            msg = op(t.month, t.day)
          rescue => e
            msg = '日付の入力を直してください 月/日'
          end
        end
        
        if not msg.nil?
          message = {
            type: 'text',
            text: msg
          }
          client.reply_message(event['replyToken'], message)
        end
      when Line::Bot::Event::MessageType::Text
        data = Hash[URI::decode_www_form(event.postback.data)]
        case data.type
        when 'dept'
          m = MessageButton.new('学部選択中')
          case data.department
          when 'igaku'
           # m.pushButton('6年生', {"data": "type=grade&year=6&department="+data.department})
           # m.pushButton('5年生', {"data": "type=grade&year=5&department="+data.department})
            m.pushButton('4年生', {"data": "type=grade&year=4&department="+data.department})
            m.pushButton('3年生', {"data": "type=grade&year=3&department="+data.department})
            m.pushButton('2年生', {"data": "type=grade&year=2&department="+data.department})
            m.pushButton('1年生', {"data": "type=grade&year=1&department="+data.department})
            client.reply_message(event['replyToken'], m.reply('学年選択', '学年を教えてください'))
          when 'kango' 
            m.pushButton('4年生', {"data": "type=grade&year=4&department="+data.department})
            m.pushButton('3年生', {"data": "type=grade&year=3&department="+data.department})
            m.pushButton('2年生', {"data": "type=grade&year=2&department="+data.department})
            m.pushButton('1年生', {"data": "type=grade&year=1&department="+data.department})
            client.reply_message(event['replyToken'], m.reply('学年選択', '学年を教えてください'))
          end
        end
      end
    when Line::Bot::Event::Join
    when Line::Bot::Event::Follow
      m = MessageButton.new('学部選択中')
      m.pushButton('医学部',   {"data": "type=dept&department=igaku"})
      m.pushButton('看護学部', {"data": "type=dept&department=kango"})
      client.reply_message(event['replyToken'], m.reply('学部選択', '学部を教えてください'))
    end
  end

  "OK"
end