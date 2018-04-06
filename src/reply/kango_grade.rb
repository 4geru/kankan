def kango_grade(event)
  m = MessageButton.new('学年選択中')
  m.pushButton('1年', {"data": "type=grade&department=kango&grade=1"})
  m.pushButton('2年', {"data": "type=grade&department=kango&grade=2"})
  m.pushButton('3年', {"data": "type=grade&department=kango&grade=3"})
  m.pushButton('4年', {"data": "type=grade&department=kango&grade=4"})
  client.reply_message(event['replyToken'], [sticky, m.reply('看護学科 > 学年選択', '学年を教えてね！')])
end