def textNewFunc(event)
  m = MessageButton.new('アンケート選択中')
  m.pushButton('する',   {"type": "uri", "uri": "https://goo.gl/forms/LX279L52DN1tNfHJ2"})
  m.pushButton('しない', {"data": "type=grade&department=kango&grade=1"})
  client.reply_message(event['replyToken'], [sticky, m.reply('アンケートに答えてね', '新機能・要望か追加されるかもしれないよ！！')])
end