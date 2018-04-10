require './src/lib/sticky'
require './src/bus_strt_at'
require './src/lib/get_timetable'
require './src/lib/get_endtime'
require './src/lib/get_exam'
require './src/event/postback'
require './src/reply/help'
require './src/reply/igaku_grade'
require './src/reply/kango_grade'
require './src/reply/select_college'
require './src/event/text/text_bus'
require './src/event/text/text_endtime'
require './src/event/text/text_timetable'
require './src/event/text/text_update'
require './src/event/text/text_new_func'
require './src/event/text/text_exam'
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
        room  = Room.find_by(channel_id: event["source"]["userId"])
        selectCollege(event) if not room
        if event.message['text'] =~ /時間割教えて？/
          text_timetable(event)
        elsif event.message['text'] =~ /テスト教えて？/
          text_exam(event)
        elsif event.message['text'] =~ /カンカン教えて？/
          p 'rub help'
          help(event['replyToken'])
        elsif event.message['text'] =~ /何時まで？/
          text_endtime(event)
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
