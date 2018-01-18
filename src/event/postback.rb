def Actionpostback(event)
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
    channel_id = event["source"]["userId"]
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
  when 'update'
    puts data['status']
    case data['status']
    when 'true'
      reset(room['department'], room['year'])
      client.reply_message(event['replyToken'], { type: 'text', text: 'アップデートが完了しました' })
      puts 'done'
    when 'false'
      client.reply_message(event['replyToken'], { type: 'text', text: 'アップデートはキャンセルしたよ' })
    end
  end
end