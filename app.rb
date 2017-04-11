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
require './messagecarousel'

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
      end
    when Line::Bot::Event::Join
      m = MessageButton.new('学部選択中')
      m.pushButton('医学部',   {"data": "type=dept&department=igaku"})
      m.pushButton('看護学部', {"data": "type=dept&department=kango"})
      client.reply_message(event['replyToken'], m.reply('学部選択', '学部を教えてください'))
    when Line::Bot::Event::Follow
      m = MessageButton.new('学部選択中')
      m.pushButton('医学部',   {"data": "type=dept&department=igaku"})
      m.pushButton('看護学部', {"data": "type=dept&department=kango"})
      client.reply_message(event['replyToken'], m.reply('学部選択', '学部を教えてください'))
    when Line::Bot::Event::Postback
      data = Hash[URI::decode_www_form(event["postback"]["data"])]
      case data["type"]
      when 'dept'
        case data["department"]
        when 'igaku'
          m = MessageCarousel.new('学年選択中')
          m1 = MessageButton.new('hoge')
          m2 = MessageButton.new('hoge')
          m1.pushButton('1年', {"data": "type=grade&department=igaku&grade=1"})
          m1.pushButton('2年', {"data": "type=grade&department=igaku&grade=2"})
          m1.pushButton('3年', {"data": "type=grade&department=igaku&grade=3"})
          m2.pushButton('4年', {"data": "type=grade&department=igaku&grade=4"})
          m2.pushButton('5年', {"data": "type=grade&department=igaku&grade=5"})
          m2.pushButton('6年', {"data": "type=grade&department=igaku&grade=6"})
          m.reply([
            m1.getButtons('医学部 > 学年選択 > 低学年', '学年を教えてください'),
            m2.getButtons('医学部 > 学年選択 > 高学年', '学年を教えてください')
          ])
          client.reply_message(event['replyToken'], m.reply('医学部 > 学年選択', '学年を教えてください'))
        when 'kango' 
          m = MessageButton.new('学年選択中')
          m.pushButton('1年', {"data": "type=grade&department=igaku&grade=1"})
          m.pushButton('2年', {"data": "type=grade&department=igaku&grade=2"})
          m.pushButton('3年', {"data": "type=grade&department=igaku&grade=3"})
          m.pushButton('4年', {"data": "type=grade&department=igaku&grade=4"})
          client.reply_message(event['replyToken'], m.reply('看護学部 > 学年選択', '学年を教えてください'))
        end
      end
    end
  end

  "OK"
end