require './src/event/postback/postback_endtime'

def postback(event)
  data = Hash[URI::decode_www_form(event["postback"]["data"])]

  room = Room.find_by(channel_id: event["source"]["userId"])
  dept  = room["department"]
  grade = room["grade"]
  case data["type"]
  when 'dept'
    case data["department"]
    when 'igaku'
      igaku_grade(event)
    when 'kango'
      kango_grade(event)
    end
  when 'timetable'
    ActionTimeTable.new(event).get_detail(data)
  when 'endTime'
    ActionEndTime.new(event).get_detail(data)
  when 'exam'
    ActionExam.new(event).get_detail(data)
  when 'grade'
    room.update!({ department: data["department"], grade: data["grade"] })
    dept = (room["department"] == 'igaku' ? '医学科' : '看護学科')
    msg = "ありがとう！\n#{dept}の#{room["grade"]}年生だね！登録したよ！"
    client.reply_message(event['replyToken'], { type: 'text', text: msg })
  when 'update'
    if data['status'] == 'true'
      reset(room['department'], room['grade'])
      client.reply_message(event['replyToken'], [ sticky, { type: 'text', text: 'アップデートが完了しました' } ])
    else
      client.reply_message(event['replyToken'], [ sticky, { type: 'text', text: 'アップデートはキャンセルしたよ' } ])
    end
  when 'bus'
    if data['pin'] == 'seta'
      client.reply_message(event['replyToken'], { type: 'text', text: bus_start_at('瀬田駅') })
    else
      client.reply_message(event['replyToken'], { type: 'text', text: bus_start_at('医大西門') })
    end
  when 'help'
    case data['order']
    when 'help', 'update'
      p "reply from word"
    when 'upgrade'
      select_college(event)
    when 'calendar'
      t = Time.new(event["postback"]["params"]["date"])
      client.reply_message(event['replyToken'], { type: 'text', text: get_timetable(dept, grade, t) })
    end
  end
end