def select_college(event)
  m = MessageButton.new('学科選択中')
  m.pushButton('医学科',   {"data": "type=dept&department=igaku"})
  m.pushButton('看護学科', {"data": "type=dept&department=kango"})
  client.reply_message(event['replyToken'], [ sticky, m.reply('学科選択', '情報を登録してね！')])
end
