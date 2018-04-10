def postback_timetable(event, data)
  room = Room.where(channel_id: event["source"]["userId"])[0]
  dept  = room["department"]
  grade = room["grade"]

  t =  Time.new() #  data["order"] == 'today'
  if data["order"] == "calendar"
    y, m, d = event["postback"]["params"]["date"].split('-')
    t = Time.new(y, m, d)
  end
  msg = get_timetable(dept, grade, t)
  client.reply_message(event['replyToken'],{ type: 'text', text: msg })
end