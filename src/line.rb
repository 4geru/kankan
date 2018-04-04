require './src/event/postback'
require './src/reply/help'
require './src/reply/igaku_grade'
require './src/reply/kango_grade'
require './src/reply/select_college'
require './src/event/text/textBus'
require './src/event/text/textEndTime'
require './src/event/text/textTimeTable'
require './src/event/text/textUpdate'
require './src/event/text/textExam'
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

        if event.message['text'] =~ /foo0/
          textEndTime(event)
        elsif event.message['text'] =~ /foo1/
          textTimeTable(event)
        elsif event.message['text'] =~ /foo2/
          textBus(event)
        elsif event.message['text'] =~ /foo3/
          textExam(event)
        elsif event.message['text'] =~ /foo4/
          help(event['replyToken'])
        end
      end
    when Line::Bot::Event::Join
      client.reply_message(event['replyToken'], select_college(event))
    when Line::Bot::Event::Follow
      client.reply_message(event['replyToken'], select_college(event))
    when Line::Bot::Event::Postback
      Actionpostback(event)
    end
  end

  "OK"
end
