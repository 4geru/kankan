
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

        channel_id = event["source"]["userId"]
        room  = Room.where(channel_id: channel_id)[0]
        if room.nil?
          get_id(event["source"])
          room  = Room.where(channel_id: channel_id)[0]
        end
        if not room
          m = MessageButton.new('学科選択中')
          m.pushButton('医学科',   {"data": "type=dept&department=igaku"})
          m.pushButton('看護学科', {"data": "type=dept&department=kango"})
          client.reply_message(event['replyToken'], m.reply('学科選択', '情報を登録してね！'))
        end
        dept  = room["department"]
        grade = room["grade"]
        if (event.message['text'] =~ /何時まで/ or event.message['text'] =~ /終了時間/) and event.message['text'] =~ /今日/
          msg = getEndTime(dept, grade, t.month, t.day)
        elsif (event.message['text'] =~ /何時まで/ or event.message['text'] =~ /終了時間/) and event.message['text'] =~ /明日/
          msg = getEndTime(dept, grade, t.month, t.day + 1)
        elsif (event.message['text'] =~ /何時まで/ or event.message['text'] =~ /終了時間/) and event.message['text'] =~ /明後日/
          msg = getEndTime(dept, grade, t.month, t.day + 2)
        elsif (event.message['text'] =~ /何時まで/ or event.message['text'] =~ /終了時間/) and event.message['text'] =~ /(\d{1,2})\/(\d{1,2})/
          begin
            m = event.message['text'].match(/(\d{1,2})\/(\d{1,2})/)
            t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
            msg = getEndTime(dept, grade, m[1], m[2])
          rescue => e
            msg = '日付の入力を直してください 月/日'
          end
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間/) and event.message['text'] =~ /今日/
          msg = op(dept, grade, t.month, t.day)
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間/) and event.message['text'] =~ /明日/
          msg = op(dept, grade, (t + 1.days).month, (t + 1.days).day)
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間/) and event.message['text'] =~ /明後日/
          msg = op(dept, grade, (t + 2.days).month, (t + 2.days).day)
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間/) and event.message['text'] =~ /(\d{1,2})\/(\d{1,2})/
          begin
            m = event.message['text'].match(/(\d{1,2})\/(\d{1,2})/)
            t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
            msg = op(dept, grade, m[1], m[2])
          rescue => e
            msg = '日付の入力を直してください 月/日'
          end
        elsif (event.message['text'] =~ /授業/ or event.message['text'] =~ /時間/)
          msg = getWeekName(dept, grade, event.message['text'])
        elsif (event.message['text'] =~ /試験/ or event.message['text'] =~ /テスト/) and event.message['text'] =~ /(\d{1,2})\/(\d{1,2})/
          begin
            m = event.message['text'].match(/(\d{1,2})\/(\d{1,2})/)
            t = Time.parse("#{t.year}/#{m[1]}/#{m[2]}")
            msg = getExams(dept, grade, t.month, t.day)
          rescue => e
            msg = '日付の入力を直してください 月/日'
          end
        elsif (event.message['text'] =~ /試験/ or event.message['text'] =~ /テスト/) and event.message['text'] =~ /の/
          begin
            title = event.message['text'].split('の')[0]
            msg = getExamsTitle(dept, grade, title)
          rescue => e
            msg = 'その教科はありません'
          end
        elsif event.message['text'] =~ /カンカン/ and event.message['text'] =~ /設定/
          m = MessageButton.new('学科選択中')
          m.pushButton('医学科',   {"data": "type=dept&department=igaku"})
          m.pushButton('看護学科', {"data": "type=dept&department=kango"})
          client.reply_message(event['replyToken'], m.reply('学科選択', '設定を変更する？学科を教えてね！'))
        elsif event.message['text'] =~ /カンカン/ and (event.message['text'] =~ /ヘルプ/ or event.message['text'] =~ /help/)
          content = [
            "\u{1F4AC}[今日,曜日,日付(月/日)]の授業は？",
            "　\u{2705} 時間割を教えるよ！",
            "\u{1F4AC}[科目(略称可)]のテストは？",
            "　\u{2705} 試験を教えるよ！",
            "\u{1F4AC}[日付(月/日)]のテストは？",
            "　\u{2705} 2週間以内の試験を教えるよ！",
            "\u{1F4AC}[今日,曜日,日付(月/日)]何時まで？",
            "　\u{2705} 終わりの時間を教えてくれるよ！",
            "\u{1F4AC}カンカン設定！",
            "　\u{2705} 学科,学年を変更できるよ！",
            "\u{1F4AC}カンカンヘルプ！",
            "　\u{2705} 指示の一覧が見れるよ！"]
          msg = content.join("\n")
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
      m = MessageButton.new('学科選択中')
      m.pushButton('医学科',   {"data": "type=dept&department=igaku"})
      m.pushButton('看護学科', {"data": "type=dept&department=kango"})
      client.reply_message(event['replyToken'], m.reply('学科選択', '初めまして！カンカンです！学科を教えてね！'))
    when Line::Bot::Event::Follow
      m = MessageButton.new('学科選択中')
      m.pushButton('医学科',   {"data": "type=dept&department=igaku"})
      m.pushButton('看護学科', {"data": "type=dept&department=kango"})
      client.reply_message(event['replyToken'], m.reply('学科選択', '初めまして！カンカンです！学科を教えてね！'))
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
            m1.getButtons('医学科 > 学年選択 > 低学年', '学年を教えてね！'),
            m2.getButtons('医学科 > 学年選択 > 高学年', '学年を教えてね！')
          ]))
        when 'kango'
          m = MessageButton.new('学年選択中')
          m.pushButton('1年', {"data": "type=grade&department=kango&grade=1"})
          m.pushButton('2年', {"data": "type=grade&department=kango&grade=2"})
          m.pushButton('3年', {"data": "type=grade&department=kango&grade=3"})
          m.pushButton('4年', {"data": "type=grade&department=kango&grade=4"})
          client.reply_message(event['replyToken'], m.reply('看護学科 > 学年選択', '学年を教えてね！'))
        end
      when 'grade'
        channel_id = event["source"]["userId"]#get_id(event["source"])
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
        dept = (room["department"] == 'igaku' ? '医学科' : '看護学科')
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