require './src/lib/sticky'
require './src/lib/bus_start_at'
require './src/event/postback'
require './src/reply/help'
require './src/reply/igaku_grade'
require './src/reply/kango_grade'
require './src/reply/select_college'
require './src/event/text/text_bus'
require './src/event/text/text_update'
require './src/event/text/text_new_func'
require './src/class/ActionExam'
require './src/class/ActionTimeTable'
require './src/class/ActionEndTime'

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
    room  = Room.find_or_create_by(channel_id: event["source"]["userId"])
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        selectCollege(event) if not room
        if event.message['text'] =~ /時間割教えて？/
          ActionTimeTable.new(event).text
        elsif event.message['text'] =~ /テスト教えて？/
          ActionExam.new(event).text
        elsif event.message['text'] =~ /カンカン教えて？/
          help(event['replyToken'])
        elsif event.message['text'] =~ /何時まで？/
          ActionEndTime.new(event).text
        elsif event.message['text'] =~ /バスの時間は？/
          text_bus(event)
        elsif event.message['text'] =~ /新機能は？/
          text_new_func(event)
        elsif  event.message['text'] =~ /時間割をアップデートして/
          text_update(event)
        end
      end
    when Line::Bot::Event::Join
      client.reply_message(event['replyToken'], select_college(event))
    when Line::Bot::Event::Follow
      client.reply_message(event['replyToken'], select_college(event))
    when Line::Bot::Event::Postback
      postback(event)
    end
  end

  "OK"
end
