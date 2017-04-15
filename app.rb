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

get '/api/:department/:grade/:month/:day' do
  protect!
  msg = op(params[:department], params[:grade], params[:month], params[:day])
end

get '/room/:room/:dept/:grade' do
  protect!
  room = Room.where(channel_id: params[:room])[0]

  if not room 
    room = Room.create({
      channel_id: params[:room],
      department: params[:dept],
      grade: params[:grade]
    })
  else
    room.update!({
      department: params[:dept],
      grade: params[:grade]
    })
  end 
end

get '/exams/:department/:grade/:month/:day' do  
  protect!
  getExams(params[:department], params[:grade], params[:month], params[:day])
end

get '/exam/:department/:grade/:title' do
  getExamsTitle(params[:department], params[:grade], params[:title])
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

        channel_id = get_id(event["source"])
        room  = Room.where(channel_id: channel_id)[0]
        dept  = room["department"]
        grade = room["grade"]
        if not room 
          m = MessageButton.new('学部選択中')
          m.pushButton('医学部',   {"data": "type=dept&department=igaku"})
          m.pushButton('看護学部', {"data": "type=dept&department=kango"})
          client.reply_message(event['replyToken'], m.reply('学部選択', '情報を登録してね！'))
        end
        if (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /今日/
          msg = op(dept, grade, t.month, t.day)
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /明日/
          msg = op(dept, grade, t.month, t.day + 1)
        elsif (event.message['text'] =~ /試験/ or event.message['text'] =~ /テスト/)  and event.message['text'] =~ /(\d{1,2})\/(\d{1,2})/
          begin
            m = event.message['text'].match(/(\d{1,2})\/(\d{1,2})/)
            t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
            msg = exams(dept, grade, t.month, t.day)
          rescue => e
            msg = '日付の入力を直してください 月/日'
          end
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間割/) and event.message['text'] =~ /(\d{1,2})\/(\d{1,2})/
          begin
            m = event.message['text'].match(/(\d{1,2})\/(\d{1,2})/)
            t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
            msg = op(dept, grade, m[1], m[2])
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
      client.reply_message(event['replyToken'], m.reply('学部選択', '初めまして！カンカンです！学部を教えてね！'))
    when Line::Bot::Event::Follow
      m = MessageButton.new('学部選択中')
      m.pushButton('医学部',   {"data": "type=dept&department=igaku"})
      m.pushButton('看護学部', {"data": "type=dept&department=kango"})
      client.reply_message(event['replyToken'], m.reply('学部選択', '初めまして！カンカンです！学部を教えてね！'))
    when Line::Bot::Event::Postback
      data = Hash[URI::decode_www_form(event["postback"]["data"])]
      case data["type"]
      when 'dept'
        case data["department"]
        when 'igaku'
          m  = MessageCarousel.new('学年選択中')
          m1 = MessageButton.new('hoge')
          m2 = MessageButton.new('hoge')
          m1.pushButton('1年', {"data": "type=grade&department=igaku&grade=1"})
          m1.pushButton('2年', {"data": "type=grade&department=igaku&grade=2"})
          m1.pushButton('3年', {"data": "type=grade&department=igaku&grade=3"})
          m2.pushButton('4年', {"data": "type=grade&department=igaku&grade=4"})
          m2.pushButton('5年', {"data": "type=grade&department=igaku&grade=5"})
          m2.pushButton('6年', {"data": "type=grade&department=igaku&grade=6"})
          client.reply_message(event['replyToken'], m.reply([
            m1.getButtons('医学部 > 学年選択 > 低学年', '学年を教えてね！'),
            m2.getButtons('医学部 > 学年選択 > 高学年', '学年を教えてね！')
          ]))
        when 'kango' 
          m = MessageButton.new('学年選択中')
          m.pushButton('1年', {"data": "type=grade&department=kango&grade=1"})
          m.pushButton('2年', {"data": "type=grade&department=kango&grade=2"})
          m.pushButton('3年', {"data": "type=grade&department=kango&grade=3"})
          m.pushButton('4年', {"data": "type=grade&department=kango&grade=4"})
          client.reply_message(event['replyToken'], m.reply('看護学部 > 学年選択', '学年を教えてね！'))
        end
      when 'grade'
        channel_id = get_id(event["source"])
        room = Room.where(channel_id: channel_id)[0]

        if not room 
          room = Room.create({
            channel_id: channel_id,
            department: data["department"],
            grade: data["grade"]
          })
        else
          room.update!({
            department: data["department"],
            grade: data["grade"]
          })
        end  
        dept = (room["department"] == 'igaku' ? '医学部' : '看護学部')
        word = "ありがとう！\n#{dept}の#{room["grade"]}年生だね！登録したよ！"
        message = {
          type: 'text',
          text: word
        }
        client.reply_message(event['replyToken'], message)       
      end
      
    end
  end

  "OK"
end