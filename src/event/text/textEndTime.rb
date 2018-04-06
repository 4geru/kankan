def textEndTime(event)
  m  = MessageCarousel.new('終了時間選択中')
  m1 = MessageButton.new('hoge')
  m1.pushButton('今日の授業', {"data": "type=endTime&order=today"})
  m1.pushButton('日付を選択', {
    "type": "datetimepicker",
    "data": "type=endTime&order=calendar",
    "text": "調べたい日を伝える！",
    "mode": "date"
  })
  reply = m.reply([ m1.getButtons('終了時間検索', '探したい日付を教えてね！') ])
  client.reply_message(event['replyToken'], [ sticky, reply])
end