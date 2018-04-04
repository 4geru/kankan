def igaku_grade(event)
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
end