def postbackEndTime(event, data)
  room = Room.where(channel_id: event["source"]["userId"])[0]
  dept  = room["department"]
  grade = room["grade"]
  case data["order"]
  when "today"
    t = Time.new()
    msg = getEndTime(dept, grade, t)
    client.reply_message(event['replyToken'],{ type: 'text', text: msg })
  when "calendar"
    y, m, d = event["postback"]["params"]["date"].split('-')
    t = Time.new(y, m, d)
    msg = getEndTime(dept, grade, t)
    client.reply_message(event['replyToken'], { type: 'text', text: msg })
  end
end