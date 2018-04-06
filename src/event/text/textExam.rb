def textExam(event)
  m  = MessageCarousel.new('テスト期間を選択中')
  m1 = MessageButton.new('hoge')
  m1.pushButton("\u{1F4CD} 今日の授業", {"data": "type=exam&order=today"})
  m1.pushButton("\u{1F4C5} 日付を選択", {
    "type": "datetimepicker",
    "data": "type=exam&order=calendar",
    "text": "調べたい日を伝える！",
    "mode": "date"
  })
  reply = m.reply([ m1.getButtons('テスト検索', '探したい日付を教えてね！') ])
  client.reply_message(event['replyToken'], [ sticky, reply ])
end