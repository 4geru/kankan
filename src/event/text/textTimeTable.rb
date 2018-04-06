def textTimeTable(event)
  m  = MessageCarousel.new('授業日を選択中')
  m1 = MessageButton.new('hoge')
  m1.pushButton('今日の授業', {"data": "type=timetable&order=today"})
  m1.pushButton('日付を選択', {
    "type": "datetimepicker",
    "data":"type=timetable&order=calendar",
    "text": "調べたい日を伝える！",
    "mode": "date"
  })
  reply = m.reply([ m1.getButtons('授業検索', '探したい日付を教えてね！') ])
  client.reply_message(event['replyToken'], [ sticky, reply ])
end